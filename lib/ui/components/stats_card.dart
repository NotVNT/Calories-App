import 'package:flutter/material.dart';
import '../../models/profile.dart';

/// Small summary card showing basic profile stats: weight, height and BMI.
class StatsCard extends StatelessWidget {
  final Profile profile;

  const StatsCard({super.key, required this.profile});

  double? _bmi() {
    final w = profile.weightKg;
    final h = profile.heightCm;
    if (w == null || h == null || h <= 0) return null;
    final m = h / 100.0;
    return w / (m * m);
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Mục tiêu: ${profile.goal}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Cập nhật: ${profile.updatedAt != null ? profile.updatedAt!.toLocal().toString().split('.').first : '—'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Cân nặng', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  profile.weightKg != null
                      ? '${profile.weightKg!.toStringAsFixed(1)} kg'
                      : '—',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text('Chiều cao', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  profile.heightCm != null
                      ? '${profile.heightCm!.toStringAsFixed(0)} cm'
                      : '—',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text('BMI', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  bmi != null ? bmi.toStringAsFixed(1) : '—',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
