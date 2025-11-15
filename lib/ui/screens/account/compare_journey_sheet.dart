import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
// cloud_firestore import removed; use ProfileService via provider for writes

import '../../../providers/compare_journey_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../services/firebase_service.dart';

class CompareJourneySheet extends StatefulWidget {
  const CompareJourneySheet({super.key});

  @override
  State<CompareJourneySheet> createState() => _CompareJourneySheetState();
}

class _CompareJourneySheetState extends State<CompareJourneySheet> {
  bool _isSharing = false;
  bool _isSaving = false;
  double? _currentWeight;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<Map<String, double?>> _askWeights(
    BuildContext ctx, {
    double? current,
  }) async {
    final startCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    if (current != null) {
      // show current weight as a hint in the dialog
      // not pre-filling the start/target to let user enter their numbers
    }

    final res = await showDialog<Map<String, double?>>(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          title: const Text('Thông tin cân nặng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cân nặng bắt đầu (kg)',
                ),
              ),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Mục tiêu (kg)'),
              ),
              if (current != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Cân nặng hiện tại: ${current.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final s = double.tryParse(startCtrl.text.replaceAll(',', '.'));
                final t = double.tryParse(targetCtrl.text.replaceAll(',', '.'));
                Navigator.of(ctx).pop({'start': s, 'target': t});
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return {
      'start': res == null ? null : res['start'],
      'target': res == null ? null : res['target'],
    };
  }

  Future<void> _pick(BuildContext ctx, bool left) async {
    final provider = ctx.read<CompareJourneyProvider>();
    final source = await showModalBottomSheet<ImageSource?>(
      context: ctx,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    if (left) {
      await provider.pickLeft(source);
    } else {
      await provider.pickRight(source);
    }
    setState(() {});
  }

  Future<void> _share(BuildContext ctx) async {
    final provider = ctx.read<CompareJourneyProvider>();
    setState(() => _isSharing = true);
    try {
      final profProv = ctx.read<ProfileProvider>();
      final profile = profProv.profile;
      // _askWeights shows a dialog using the provided BuildContext. We capture
      // all needed values above and avoid using the context after awaits.
      // The dialog itself requires a context; ignore the lint about using
      // the context synchronously here.
      // ignore: use_build_context_synchronously
      final weights = await _askWeights(ctx, current: profile.weightKg);
      if (!mounted) return;
      final combined = await provider.createDecoratedCombinedImage(
        saveToHistory: true,
        startKg: weights['start'],
        currentKg: profile.weightKg,
        targetKg: weights['target'],
      );
      if (combined == null) return;
      // Use share_plus to share generated image file.
      // The static facade is deprecated in newer versions; suppress the
      // deprecation lint here to preserve functionality until a full
      // migration to the new instance API is done.
      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(combined.path),
      ], text: 'So sánh hành trình cân nặng của tôi');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  Future<void> _saveMeasurement(BuildContext ctx) async {
    final prov = ctx.read<CompareJourneyProvider>();
    // allow saving when at least one image exists
    if (!prov.hasLeft && !prov.hasRight) return;
    // Capture messenger and navigator before any `await` to avoid
    // use_build_context_synchronously lint (using ctx after async gaps).
    final scaffoldMessenger = ScaffoldMessenger.of(ctx);
    final navigator = Navigator.of(ctx);
    setState(() => _isSaving = true);
    try {
      final profProv = ctx.read<ProfileProvider>();
      final profile = profProv.profile;
      // Use provided current weight if set, else fallback to profile
      final current = _currentWeight ?? profile.weightKg;
      if (current == null) throw Exception('Cân nặng không hợp lệ');

      File? combined;
      if (prov.hasLeft && prov.hasRight) {
        combined = await prov.createDecoratedCombinedImage(
          saveToHistory: true,
          currentKg: current,
        );
      } else {
        // single photo: pick whichever exists
        final single = prov.leftFile() ?? prov.rightFile();
        if (single == null) throw Exception('Không có ảnh để lưu');
        combined = await prov.createDecoratedSingleImage(
          single,
          saveToHistory: true,
          currentKg: current,
        );
      }
      if (combined == null) throw Exception('Tạo ảnh thất bại');

      final uid = FirebaseAuth.instance.currentUser?.uid;
      String? imageUrl;
      if (uid != null) {
        FirebaseService.ensureCanWrite();
        final storage = FirebaseService.storage;
        final ts = DateTime.now().millisecondsSinceEpoch;
        final ref = storage.ref('measurements/$uid/$ts.png');
        await ref.putFile(combined);
        imageUrl = await ref.getDownloadURL();

        // Persist measurement via ProfileProvider to ensure history + latest are updated
        await profProv.saveMeasurement(
          type: 'weight',
          value: current,
          unit: 'kg',
          imageUrl: imageUrl,
        );
      } else {
        throw Exception('Người dùng chưa đăng nhập');
      }

      if (!mounted) return;
      // Use captured messenger/navigator instead of ctx after async gaps
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Lưu lịch sử cân nặng thành công')),
      );
      navigator.pop();
    } catch (e, st) {
      debugPrint('Save measurement failed: $e\n$st');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lưu thất bại: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openPreview(BuildContext ctx) {
    final provider = ctx.read<CompareJourneyProvider>();
    final l = provider.leftFile();
    final r = provider.rightFile();
    if (l == null || r == null) return;
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: _BeforeAfterPreview(left: l, right: r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1726),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            // Current weight input row with stepper
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 6.0,
              ),
              child: Consumer<ProfileProvider>(
                builder: (ctx, profProv, _) {
                  final profile = profProv.profile;
                  final initial = profile.weightKg;
                  // initialize controller text only once after we have profile
                  if ((_weightController.text.isEmpty) && initial != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _weightController.text.isEmpty) {
                        _weightController.text = initial.toStringAsFixed(1);
                        _currentWeight = initial;
                      }
                    });
                  }
                  return Row(
                    children: [
                      const Text(
                        'Cân nặng hiện tại:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final cur = _currentWeight ?? initial ?? 0.0;
                                final next = (cur - 0.1).clamp(0.0, 999.0);
                                setState(() {
                                  _currentWeight = double.parse(
                                    next.toStringAsFixed(1),
                                  );
                                  _weightController.text = _currentWeight!
                                      .toStringAsFixed(1);
                                });
                              },
                            ),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: _weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  filled: true,
                                  fillColor: Color(0xFF2A2233),
                                  hintText: '',
                                ),
                                onChanged: (v) {
                                  final n = double.tryParse(
                                    v.replaceAll(',', '.'),
                                  );
                                  setState(() => _currentWeight = n);
                                },
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                final cur = _currentWeight ?? initial ?? 0.0;
                                final next = (cur + 0.1).clamp(0.0, 999.0);
                                setState(() {
                                  _currentWeight = double.parse(
                                    next.toStringAsFixed(1),
                                  );
                                  _weightController.text = _currentWeight!
                                      .toStringAsFixed(1);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Text(
              'So sánh hành trình thay đổi',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pick(context, true),
                    child: Consumer<CompareJourneyProvider>(
                      builder: (ctx, prov, _) {
                        final has = prov.hasLeft;
                        return SizedBox(
                          height: 120,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: has
                                      ? Colors.deepPurple.shade300
                                      : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(10),
                                  image: has && prov.leftPath != null
                                      ? DecorationImage(
                                          image: FileImage(
                                            File(prov.leftPath!),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                height: 120,
                              ),
                              if (!has)
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Thêm ảnh để bắt đầu ghi lại hành trình cân nặng',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // overlay actions
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Row(
                                  children: [
                                    if (has)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () => _pick(context, true),
                                      ),
                                    if (has)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          await prov.clearLeft();
                                          setState(() {});
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pick(context, false),
                    child: Consumer<CompareJourneyProvider>(
                      builder: (ctx, prov, _) {
                        final has = prov.hasRight;
                        return Stack(
                          children: [
                            SizedBox(
                              height: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: has
                                      ? Colors.deepPurple.shade300
                                      : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(10),
                                  image: has && prov.rightPath != null
                                      ? DecorationImage(
                                          image: FileImage(
                                            File(prov.rightPath!),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            if (!has)
                              const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Row(
                                children: [
                                  if (has)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      onPressed: () => _pick(context, false),
                                    ),
                                  if (has)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      onPressed: () async {
                                        await prov.clearRight();
                                        setState(() {});
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // history thumbnails
            FutureBuilder<List<String>>(
              future: context.read<CompareJourneyProvider>().getHistoryPaths(),
              builder: (ctx, snap) {
                final list = snap.data ?? [];
                if (list.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (c, i) {
                      final p = list[i];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: Image.file(File(p), fit: BoxFit.contain),
                            ),
                          );
                        },
                        onLongPress: () async {
                          final provRef = context
                              .read<CompareJourneyProvider>();
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Xóa ảnh lưu'),
                              content: const Text(
                                'Bạn có muốn xóa ảnh này khỏi lịch sử?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await provRef.removeHistoryEntry(p);
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(p)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: list.length,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Consumer<CompareJourneyProvider>(
                    builder: (ctx, prov, _) {
                      return ElevatedButton(
                        onPressed: prov.hasLeft && prov.hasRight
                            ? () => _openPreview(ctx)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2B88),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Xem so sánh'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<CompareJourneyProvider>(
                    builder: (ctx, prov, _) {
                      return ElevatedButton(
                        onPressed: prov.hasLeft && prov.hasRight && !_isSharing
                            ? () => _share(ctx)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2B88),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isSharing
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Chia sẻ'),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Save button row
            Consumer<CompareJourneyProvider>(
              builder: (ctx, prov, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (prov.hasLeft || prov.hasRight) && !_isSaving
                        ? () => _saveMeasurement(ctx)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9A7FFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Ghi lại'),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BeforeAfterPreview extends StatefulWidget {
  final File left;
  final File right;
  const _BeforeAfterPreview({required this.left, required this.right});

  @override
  State<_BeforeAfterPreview> createState() => _BeforeAfterPreviewState();
}

class _BeforeAfterPreviewState extends State<_BeforeAfterPreview> {
  double _divider = 0.5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(child: Image.file(widget.right, fit: BoxFit.cover)),
            // left image clipped by divider
            Positioned.fill(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final w = constraints.maxWidth * _divider;
                  return Stack(
                    children: [
                      Positioned(
                        width: w,
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Image.file(widget.left, fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: w - 12,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragUpdate: (e) {},
                          onPanUpdate: (e) {
                            final box = context.findRenderObject() as RenderBox;
                            final local = box.globalToLocal(e.globalPosition);
                            setState(
                              () => _divider = (local.dx / box.size.width)
                                  .clamp(0.0, 1.0),
                            );
                          },
                          child: Container(
                            width: 24,
                            color: Colors.transparent,
                            child: Center(
                              child: Container(width: 3, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
