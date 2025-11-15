import 'package:flutter/material.dart';

import 'package:calories_app/core/theme/app_colors.dart';
import 'package:calories_app/features/meals/domain/meal_plan.dart';

class MealCategoryChip extends StatelessWidget {
  const MealCategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
  });

  final MealCategory category;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? category.accent.withAlpha((0.9 * 255).round())
            : category.accent.withAlpha((0.18 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? category.accent
              : AppColors.charmingGreen.withAlpha((0.4 * 255).round()),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            color: AppColors.nearBlack,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            category.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.nearBlack,
                ),
          ),
        ],
      ),
    );
  }
}


