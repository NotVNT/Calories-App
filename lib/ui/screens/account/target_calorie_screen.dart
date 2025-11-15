// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';

class TargetCalorieScreen extends StatefulWidget {
  const TargetCalorieScreen({super.key});

  @override
  State<TargetCalorieScreen> createState() => _TargetCalorieScreenState();
}

class _TargetCalorieScreenState extends State<TargetCalorieScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prov = context.read<ProfileProvider>();
    final current = prov.profile.calorieTarget?.toString() ?? '1752';
    _ctrl = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmr = 1460; // placeholder; compute from profile if you have data

    return Scaffold(
      appBar: AppBar(title: const Text('Calo mục tiêu')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.deepOrange,
                      size: 46,
                    ),
                    const SizedBox(height: 14),
                    // Editable calorie input (large)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _ctrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Nhập số calo';
                              }
                              final n = int.tryParse(v.replaceAll(',', ''));
                              if (n == null || n <= 0) {
                                return 'Nhập số hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'BMR của bạn đang là $bmr',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Explanatory paragraph
                    Text(
                      'Tự điều chỉnh calo có thể ảnh hưởng đến sức khỏe và mục tiêu nếu bạn chưa hiểu rõ nhu cầu dinh dưỡng của mình.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom action button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    final raw = _ctrl.text.replaceAll(',', '').trim();
                    final n = int.tryParse(raw);
                    if (n == null) {
                      return;
                    }
                    final prov = context.read<ProfileProvider>();
                    final current = prov.profile;
                    await prov.updateProfile(
                      current.copyWith(calorieTarget: n),
                    );
                    // return success to caller so it can show SnackBar
                    if (mounted) Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Cập nhật',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
