import 'package:flutter/material.dart';

/// Enum cho các loại bữa ăn
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Bữa sáng';
      case MealType.lunch:
        return 'Bữa trưa';
      case MealType.dinner:
        return 'Bữa tối';
      case MealType.snack:
        return 'Bữa phụ';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.wb_sunny;
      case MealType.dinner:
        return Icons.nightlight_outlined;
      case MealType.snack:
        return Icons.fastfood_outlined;
    }
  }

  Color get color {
    switch (this) {
      case MealType.breakfast:
        return const Color(0xFFFFB74D); // Orange
      case MealType.lunch:
        return const Color(0xFF4FC3F7); // Light Blue
      case MealType.dinner:
        return const Color(0xFF9575CD); // Purple
      case MealType.snack:
        return const Color(0xFF81C784); // Green
    }
  }
}

