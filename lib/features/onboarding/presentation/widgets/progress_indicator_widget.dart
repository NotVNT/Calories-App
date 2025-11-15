import 'package:flutter/material.dart';
import 'package:calories_app/core/theme/theme.dart';

/// Custom progress indicator for onboarding
class ProgressIndicatorWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress percentage text
        Text(
          '${(progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGray,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.charmingGreen.withAlpha((0.3 * 255).round()),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mintGreen),
          ),
        ),
      ],
    );
  }
}


