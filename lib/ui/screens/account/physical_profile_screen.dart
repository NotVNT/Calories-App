// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';
import 'measurements/measurement_editor_screen.dart';
// import 'edit_profile_screen.dart';

class PhysicalProfileScreen extends StatelessWidget {
  const PhysicalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final theme = Theme.of(context);

    final String gender = '-';
    final String age = '-';
    final String height = profile.heightCm != null
        ? '${profile.heightCm!.toInt()} cm'
        : '-';
    final String weight = profile.weightKg != null
        ? '${profile.weightKg!.round()} Kg'
        : '-';
    final measurements = profile.measurements ?? {};

    String displayFor(String title) {
      final tl = title.toLowerCase();
      String key;
      if (tl.contains('cân nặng') || tl.contains('weight')) {
        key = 'weight';
      } else if (tl.contains('chiều cao') || tl.contains('height')) {
        key = 'height';
      } else if (tl.contains('%') || tl.contains('tỷ lệ')) {
        key = 'body_fat';
      } else {
        key = tl.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      }

      if (!measurements.containsKey(key)) {
        return title.toLowerCase().contains('%') || tl.contains('tỷ lệ')
            ? '-'
            : '- cm';
      }
      final val = measurements[key]!;
      if (key == 'weight') return '${val.round()} Kg';
      if (key == 'height') return '${val.toInt()} cm';
      if (key == 'body_fat') return '${val.toStringAsFixed(2)}%';
      // default: length in cm
      return '${val.toStringAsFixed(1)} cm';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ thể chất')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Thông tin cơ bản',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Basic info card styled like the mock: small label, name, three small stats and edit button
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NICKNAME',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit button as small circular icon to match mock
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.of(
                            context,
                          ).pushNamed('/edit_profile');
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                        tooltip: 'Chỉnh sửa',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statItem(context, 'GIỚI TÍNH', gender),
                    const SizedBox(width: 8),
                    _statItem(context, 'TUỔI', age),
                    const SizedBox(width: 8),
                    _statItem(context, 'CHIỀU CAO', height),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          Text(
            'Mục tiêu cân nặng',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Duy trì cân nặng', style: theme.textTheme.bodyMedium),
                    Text(
                      weight,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Mục tiêu hằng tuần'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed('/weekly_goal'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Cường độ vận động'),
                  subtitle: Text('-'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/activity_detail'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Calo mục tiêu'),
                  trailing: Text(
                    '${profile.calorieTarget ?? '-'} calo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Dự kiến hoàn thành'),
                  trailing: const Text('-'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.of(context).pushNamed('/setup_goal');
              },
              icon: const Icon(Icons.repeat),
              label: const Text('Thiết lập mục tiêu mới'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),
          Text(
            'Chỉ số sức khỏe và đo lường',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Large body fat card with edit button
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('% Body fat', style: theme.textTheme.bodyLarge),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showEditMeasurement(context, '% Body fat', ''),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _measureCard(context, 'Vòng cổ', displayFor('Vòng cổ')),
              _measureCard(context, 'Vòng ngực', displayFor('Vòng ngực')),
              _measureCard(context, 'Vòng eo', displayFor('Vòng eo')),
              _measureCard(context, 'Vòng hông', displayFor('Vòng hông')),
              _measureCard(context, 'Bắp tay', displayFor('Bắp tay')),
              _measureCard(
                context,
                'Tỷ lệ eo hông',
                displayFor('Tỷ lệ eo hông'),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _measureCard(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 24,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('So với lần trước', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showEditMeasurement(context, title, value),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditMeasurement(
    BuildContext context,
    String title,
    String current,
  ) {
    // Parse numeric part from current value if possible (e.g. "70.0 cm" -> 70.0)
    double initial = 0.0;
    try {
      if (current != '-' && current.isNotEmpty) {
        final numPart = RegExp(r"[0-9]+(?:\\.[0-9]+)?").firstMatch(current);
        if (numPart != null) initial = double.parse(numPart.group(0)!);
      }
    } catch (_) {
      initial = 0.0;
    }

    // Decide unit and sensible min/max by title
    String unit = '';
    double min = 0;
    double max = 200;
    int decimals = 1;
    if (title.toLowerCase().contains('tỷ lệ') ||
        title.toLowerCase().contains('%')) {
      unit = title.toLowerCase().contains('%') ? '%' : '';
      min = 0;
      max = 1.0;
      decimals = 2;
    } else {
      unit = 'cm';
      min = 0;
      max = 200;
      decimals = 1;
    }

    Navigator.of(context)
        .push<double>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => MeasurementEditorScreen(
              title: 'Số đo $title',
              unit: unit,
              min: min,
              max: max,
              initialValue: initial,
              decimals: decimals,
              // try to use an asset named after the slug of the title (best-effort)
              imageAsset:
                  'assets/images/measure_${title.toLowerCase().replaceAll(' ', '_').replaceAll('%', 'percent')}.png',
              typeKey: (() {
                final tl = title.toLowerCase();
                if (tl.contains('cân nặng') || tl.contains('weight')) {
                  return 'weight';
                }
                if (tl.contains('chiều cao') || tl.contains('height')) {
                  return 'height';
                }
                if (tl.contains('%') || tl.contains('tỷ lệ')) {
                  return 'body_fat';
                }
                return tl.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
              })(),
            ),
          ),
        )
        .then((res) async {
          if (res != null) {
            final display =
                res.toStringAsFixed(decimals) +
                (unit.isNotEmpty ? ' $unit' : '');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title đã cập nhật: $display')),
            );
          }
        });
  }

  Widget _statItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
