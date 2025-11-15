// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';

class DietModeScreen extends StatefulWidget {
  const DietModeScreen({super.key});

  @override
  State<DietModeScreen> createState() => _DietModeScreenState();
}

class _DietModeScreenState extends State<DietModeScreen> {
  String? _selectedKey;

  void _select(String key) {
    setState(() => _selectedKey = key);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn chế độ ăn'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // chat bubble header imitation
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.pets, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Hãy chọn chế độ ăn mà bạn muốn',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // list of options
            Expanded(
              child: ListView(
                children: [
                  _dietCard(
                    keyId: 'high_protein',
                    title: 'Ít tinh bột - Tăng đạm',
                    desc:
                        'Giàu đạm, ít carb, hỗ trợ duy trì khối cơ. Thích hợp cho người tập luyện.',
                    icon: Icons.set_meal,
                  ),
                  const SizedBox(height: 12),
                  _dietCard(
                    keyId: 'keto',
                    title: 'Keto',
                    desc:
                        'Giàu chất béo, rất ít tinh bột, đủ đạm. Dành cho người muốn ăn kiêng low-carb nghiêm ngặt',
                    icon: Icons.opacity,
                  ),
                  const SizedBox(height: 12),
                  _dietCard(
                    keyId: 'balanced',
                    title: 'Cân bằng',
                    desc:
                        'Phân bổ đều carb, đạm, chất béo. Phù hợp với hầu hết mọi người',
                    icon: Icons.balance,
                  ),
                ],
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: _selectedKey == null
                      ? null
                      : () async {
                          final prov = context.read<ProfileProvider>();
                          final current = prov.profile;
                          final goalText = 'diet:$_selectedKey';
                          await prov.updateProfile(
                            current.copyWith(goal: goalText),
                          );
                          if (mounted) Navigator.of(context).pop(true);
                        },
                  child: Text(
                    'Tiếp tục',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _dietCard({
    required String keyId,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final selected = _selectedKey == keyId;
    return GestureDetector(
      onTap: () => _select(keyId),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(desc, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ],
        ),
      ),
    );
  }
}
