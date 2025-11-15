// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// A simple circular indicator that shows progress toward a calorie target.
class MacroRing extends StatelessWidget {
  final int currentCalories;
  final int targetCalories;
  final double size;

  const MacroRing({
    super.key,
    required this.currentCalories,
    required this.targetCalories,
    this.size = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    final pct = targetCalories > 0
        ? (currentCalories / targetCalories).clamp(0.0, 1.0)
        : 0.0;
    final label = '$currentCalories / $targetCalories kcal';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: pct,
              strokeWidth: 12,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(pct * 100).round()}%',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
