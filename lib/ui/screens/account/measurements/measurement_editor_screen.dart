import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calories_app/providers/profile_provider.dart';

import 'package:calories_app/services/firebase_service.dart';
import 'package:calories_app/providers/compare_journey_provider.dart';
import '../compare_journey_sheet.dart';

class MeasurementEditorScreen extends StatefulWidget {
  final String title;
  final String unit;
  final double min;
  final double max;
  final double initialValue;
  final int decimals;
  final String? imageAsset;
  final String typeKey;

  const MeasurementEditorScreen({
    super.key,
    required this.title,
    required this.unit,
    this.min = 0,
    this.max = 200,
    this.initialValue = 0,
    this.decimals = 1,
    this.imageAsset,
    required this.typeKey,
  });

  @override
  State<MeasurementEditorScreen> createState() =>
      _MeasurementEditorScreenState();
}

class _MeasurementEditorScreenState extends State<MeasurementEditorScreen> {
  late double value;
  File? _pickedImage;
  // image picker instance removed; using CompareJourneyProvider.pickRight instead

  @override
  void initState() {
    super.initState();
    value = widget.initialValue.clamp(widget.min, widget.max);
  }

  String get formattedValue {
    return value.toStringAsFixed(widget.decimals) +
        (widget.unit.isNotEmpty ? ' ${widget.unit}' : '');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final prov = Provider.of<CompareJourneyProvider>(context, listen: false);
      // Use provider to pick and save the right-side image so history/persistence
      // is consistent with the compare flow.
      await prov.pickRight(source);
      final f = prov.rightFile();
      if (f != null) setState(() => _pickedImage = f);
    } catch (e, st) {
      debugPrint('Image pick failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // background gradient top
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0xFF3A0B73), Color(0x00000000)],
                ),
              ),
            ),
            Column(
              children: [
                // header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // illustration area
                      // Photo area: tap to add / compare journey
                      GestureDetector(
                        onTap: () async {
                          try {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const CompareJourneySheet(),
                            );
                          } catch (e, st) {
                            // Defensive: surface errors so user sees why sheet didn't open
                            debugPrint(
                              'Open CompareJourneySheet failed: $e\n$st',
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Không thể mở so sánh ảnh: $e'),
                                ),
                              );
                            }
                          }
                        },
                        child: SizedBox(
                          height: 180,
                          child: Stack(
                            children: [
                              // Show picked image if available first, else asset or placeholder
                              Positioned.fill(
                                child: _pickedImage != null
                                    ? Image.file(
                                        _pickedImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 48,
                                                color: Colors.white24,
                                              ),
                                            ),
                                      )
                                    : (widget.imageAsset != null
                                          ? Image.asset(
                                              widget.imageAsset!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (ctx, err, stack) =>
                                                  const Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 64,
                                                    color: Colors.white24,
                                                  ),
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 48,
                                                  color: Colors.white24,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  '+ Thêm ảnh chụp',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                              ],
                                            )),
                              ),
                              // small action buttons on top-right: camera / gallery
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.photo_library,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _pickImage(ImageSource.gallery),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _pickImage(ImageSource.camera),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // value
                      Text(
                        formattedValue,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 18),

                      // pointer + ruler
                      SizedBox(
                        height: 120,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Positioned.fill(
                              left: 40,
                              child: CustomPaint(
                                painter: _RulerPainter(
                                  min: widget.min,
                                  max: widget.max,
                                  divisions: 40,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                            // pointer line
                            Positioned(
                              left:
                                  40 +
                                  _valueToOffset(
                                    value,
                                    widget.min,
                                    widget.max,
                                    context,
                                  ),
                              top: 12,
                              bottom: 12,
                              child: Container(
                                width: 2,
                                color: const Color(0xFF9A7FFF),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // slider for input (hidden style)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            activeTrackColor: const Color(0xFF9A7FFF),
                            inactiveTrackColor: Colors.white10,
                          ),
                          child: Slider(
                            value: value,
                            min: widget.min,
                            max: widget.max,
                            divisions: ((widget.max - widget.min) * (10))
                                .round(),
                            onChanged: (v) => setState(() => value = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Save button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9A7FFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () async {
                        final prov = Provider.of<ProfileProvider>(
                          context,
                          listen: false,
                        );
                        String? errorMessage;
                        // create decorated combined image if left/right present
                        final compareProv = Provider.of<CompareJourneyProvider>(
                          context,
                          listen: false,
                        );
                        File? combined;
                        try {
                          combined = await compareProv
                              .createDecoratedCombinedImage(
                                saveToHistory: false,
                                currentKg: value,
                              );
                        } catch (_) {
                          combined = null;
                        }

                        try {
                          String? imageUrl;
                          File? toUpload = combined;
                          // if no combined image but user picked one in this editor, use it
                          if (toUpload == null && _pickedImage != null) {
                            toUpload = _pickedImage;
                          }
                          if (toUpload != null) {
                            final uid = prov.uid;
                            FirebaseService.ensureCanWrite();
                            final storage = FirebaseService.storage;
                            final ts = DateTime.now().millisecondsSinceEpoch;
                            final ref = storage.ref(
                              'measurements/$uid/$ts.png',
                            );
                            await ref.putFile(toUpload);
                            imageUrl = await ref.getDownloadURL();
                          }

                          // Use provider to persist measurement (history + latest)
                          await prov.saveMeasurement(
                            type: widget.typeKey,
                            value: value,
                            unit: widget.unit,
                            imageUrl: imageUrl,
                          );
                        } catch (e) {
                          errorMessage = 'Lưu lịch sử cân nặng thất bại: $e';
                        }

                        if (!mounted) return;
                        if (errorMessage != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(errorMessage)));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã lưu lịch sử cân nặng'),
                            ),
                          );
                        }
                        Navigator.of(context).pop(value);
                      },
                      child: const Text('Ghi lại'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _valueToOffset(double v, double min, double max, BuildContext ctx) {
    final width =
        MediaQuery.of(ctx).size.width - 40 - 32; // left offset + padding
    final t = ((v - min) / (max - min)).clamp(0.0, 1.0);
    return t * width;
  }
}

class _RulerPainter extends CustomPainter {
  final double min;
  final double max;
  final int divisions;
  final Color color;

  _RulerPainter({
    required this.min,
    required this.max,
    this.divisions = 20,
    this.color = Colors.white24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    final minor = 6.0;
    final major = 14.0;
    for (int i = 0; i <= divisions; i++) {
      final dx = (size.width) * (i / divisions);
      final isMajor = i % 5 == 0;
      final h = isMajor ? major : minor;
      canvas.drawLine(
        Offset(dx, size.height - h),
        Offset(dx, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
