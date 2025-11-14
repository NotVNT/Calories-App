import 'package:flutter/material.dart';

class MealPlan {
  const MealPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    required this.mealsPerDay,
    required this.durationWeeks,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.tags,
    required this.accent,
  });

  final String id;
  final String title;
  final String description;
  final int calories;
  final int mealsPerDay;
  final int durationWeeks;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> tags;
  final Color accent;
}

class MealCategory {
  const MealCategory({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;
}

