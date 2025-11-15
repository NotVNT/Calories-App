// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';
import 'target_calorie_screen.dart';
import 'macro_ratio_screen.dart';
import 'water_target_screen.dart';
import 'steps_target_screen.dart';

class TargetsScreen extends StatelessWidget {
  const TargetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>().profile;
    final calorieTarget = profile.calorieTarget ?? 1752;
    const bmr = 1460;

    return Scaffold(
      appBar: AppBar(title: const Text('Tùy chỉnh mục tiêu')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Thông tin dinh dưỡng',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Top row: big calorie + 3 small macro rings
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large calorie number
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.deepOrange,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatNumber(calorieTarget),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('CALO MỤC TIÊU', style: theme.textTheme.labelSmall),
                  ],
                ),
              ),

              // Macro rings
              Expanded(
                flex: 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _smallRing(context, 0.2, Colors.red, '20%', 'CHẤT ĐẠM'),
                    _smallRing(context, 0.5, Colors.blue, '50%', 'ĐƯỜNG BỘT'),
                    _smallRing(context, 0.3, Colors.amber, '30%', 'CHẤT BÉO'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // BMR/TDEE card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 18.0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Tỷ lệ trao đổi chất cơ bản (BMR)')),
                      Text(
                        '$bmr',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Tổng năng lượng tiêu thụ mỗi ngày (TDEE)'),
                      ),
                      Text(
                        '$calorieTarget',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Tùy chỉnh mục tiêu dinh dưỡng',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Card with two rows
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _optionTile(
                  context,
                  Icons.local_fire_department_outlined,
                  'Calo mục tiêu',
                  onTap: () async {
                    final res = await Navigator.push<bool?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TargetCalorieScreen(),
                      ),
                    );
                    if (res == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cập nhật calo mục tiêu thành công'),
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                _optionTile(
                  context,
                  Icons.pie_chart_outline,
                  'Tỷ lệ dinh dưỡng đa lượng',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MacroRatioScreen()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          Text(
            'Mục tiêu khác',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _optionTile(
                  context,
                  Icons.water_drop_outlined,
                  'Lượng nước',
                  onTap: () =>
                      Navigator.push<bool?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WaterTargetScreen(),
                        ),
                      ).then((res) {
                        if (res == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Cập nhật mục tiêu nước thành công',
                              ),
                            ),
                          );
                        }
                      }),
                ),
                const Divider(height: 1),
                _optionTile(
                  context,
                  Icons.directions_walk,
                  'Bước chân mục tiêu',
                  onTap: () async {
                    final res = await Navigator.push<bool?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StepsTargetScreen(),
                      ),
                    );
                    if (res == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cập nhật mục tiêu bước chân thành công',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _optionTile(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _smallRing(
    BuildContext context,
    double fraction,
    Color color,
    String label,
    String caption,
  ) {
    final size = 64.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: 8,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: size,
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    return s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
  }
}
