// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';

// A single, consolidated EditProfileScreen. Uses controllers and provides
// validation, then persists via ProfileProvider.updateProfile.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;
  String _goal = 'Duy trì';

  @override
  void initState() {
    super.initState();
    // Initialize controllers in didChangeDependencies since provider isn't
    // available in initState via context.read safely for some cases. Delay
    // using addPostFrameCallback to read provider once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      _nameCtrl = TextEditingController(text: profile.name);
      _emailCtrl = TextEditingController(text: profile.email ?? '');
      _weightCtrl = TextEditingController(
        text: profile.weightKg?.toString() ?? '',
      );
      _heightCtrl = TextEditingController(
        text: profile.heightCm?.toString() ?? '',
      );
      _goal = profile.goal;
      setState(() {});
    });
    // Provide temporary controllers in case build runs before callback.
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  _fieldTile(
                    context,
                    label: 'Họ và tên',
                    value: profile.name,
                    onTapRoute: '/edit_nickname',
                  ),
                  const Divider(height: 1),
                  _fieldTile(
                    context,
                    label: 'Email (tuỳ chọn)',
                    value: profile.email ?? '',
                    onTapRoute: null,
                  ),
                  const Divider(height: 1),
                  _fieldTile(
                    context,
                    label: 'Cân nặng (kg)',
                    value: profile.weightKg != null
                        ? profile.weightKg!.toStringAsFixed(1)
                        : '',
                    onTapRoute: '/setup_goal/weight',
                  ),
                  const Divider(height: 1),
                  _fieldTile(
                    context,
                    label: 'Chiều cao (cm)',
                    value: profile.heightCm != null
                        ? profile.heightCm!.toStringAsFixed(0)
                        : '',
                    onTapRoute: '/edit_height',
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 18,
                      bottom: 6,
                    ),
                    child: Text(
                      'Mục tiêu',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  RadioListTile<String>(
                    value: 'Giảm cân',
                    groupValue: _goal,
                    title: const Text('Giảm cân'),
                    onChanged: (v) => setState(() => _goal = v ?? _goal),
                  ),
                  RadioListTile<String>(
                    value: 'Duy trì',
                    groupValue: _goal,
                    title: const Text('Duy trì'),
                    onChanged: (v) => setState(() => _goal = v ?? _goal),
                  ),
                  RadioListTile<String>(
                    value: 'Tăng cơ',
                    groupValue: _goal,
                    title: const Text('Tăng cơ'),
                    onChanged: (v) => setState(() => _goal = v ?? _goal),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                  ),
                  child: const Text('Lưu'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldTile(
    BuildContext context, {
    required String label,
    required String value,
    String? onTapRoute,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: value.isEmpty
          ? null
          : Text(value, style: Theme.of(context).textTheme.titleMedium),
      trailing: onTapRoute != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTapRoute == null
          ? null
          : () => Navigator.of(context).pushNamed(onTapRoute),
    );
  }

  Future<void> _save() async {
    // The form is optional in this consolidated screen; only validate if a
    // Form widget exists and has a current state. Guard against null.
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }
    final provider = context.read<ProfileProvider>();
    final current = provider.profile;
    final updated = current.copyWith(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      weightKg: _weightCtrl.text.trim().isEmpty
          ? null
          : double.parse(_weightCtrl.text.trim()),
      heightCm: _heightCtrl.text.trim().isEmpty
          ? null
          : double.parse(_heightCtrl.text.trim()),
      goal: _goal,
      updatedAt: DateTime.now().toUtc(),
    );

    await provider.updateProfile(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu')));
    Navigator.of(context).pop();
  }
}
