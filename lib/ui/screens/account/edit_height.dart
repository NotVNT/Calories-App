import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';

class EditHeightScreen extends StatefulWidget {
  const EditHeightScreen({super.key});

  @override
  State<EditHeightScreen> createState() => _EditHeightScreenState();
}

class _EditHeightScreenState extends State<EditHeightScreen> {
  double _height = 160;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProfileProvider>().profile;
      setState(() {
        _height = p.heightCm?.toDouble() ?? 160.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.height, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Chiều cao của bạn là...',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_height.toInt()}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('cm', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 120,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(trackHeight: 2),
                      child: Slider(
                        value: _height,
                        min: 100,
                        max: 220,
                        divisions: 120,
                        onChanged: (v) => setState(() => _height = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(_saving ? 'Đang lưu...' : 'Cập nhật'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prov = context.read<ProfileProvider>();
    final updated = prov.profile.copyWith(
      heightCm: _height,
      updatedAt: DateTime.now().toUtc(),
    );
    await prov.updateProfile(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Chiều cao đã được cập nhật')));
    Navigator.of(context).pop();
  }
}
