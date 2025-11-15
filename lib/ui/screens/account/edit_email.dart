import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';

class EditEmailScreen extends StatefulWidget {
  const EditEmailScreen({super.key});

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  late TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProfileProvider>().profile;
      _ctrl.text = p.email ?? '';
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const Spacer(),
            SizedBox(
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
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final email = _ctrl.text.trim();
    if (email.isEmpty) return;
    setState(() => _saving = true);
    final prov = context.read<ProfileProvider>();
    final updated = prov.profile.copyWith(
      email: email,
      updatedAt: DateTime.now().toUtc(),
    );
    await prov.updateProfile(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Email đã được cập nhật')));
    Navigator.of(context).pop();
  }
}
