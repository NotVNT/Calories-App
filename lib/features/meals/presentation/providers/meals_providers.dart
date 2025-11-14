import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calories_app/features/meals/domain/meal_plan.dart';
import 'package:calories_app/core/theme/app_colors.dart';

final userMealPlansProvider = Provider<List<MealPlan>>((ref) {
  return const [
    MealPlan(
      id: 'user_lean_pro',
      title: 'Lean Pro 1500',
      description: 'Giảm mỡ khoa học với 5 bữa ăn cân bằng mỗi ngày.',
      calories: 1500,
      mealsPerDay: 5,
      durationWeeks: 4,
      protein: 120,
      carbs: 150,
      fat: 45,
      tags: ['Giảm mỡ', 'Dễ nấu', 'Bận rộn'],
      accent: Color(0xFF8BC6EC),
    ),
    MealPlan(
      id: 'user_balance',
      title: 'Balanced Lifestyle 1900',
      description: 'Giữ dáng khỏe mạnh với tỉ lệ macro vàng 40/35/25.',
      calories: 1900,
      mealsPerDay: 4,
      durationWeeks: 6,
      protein: 140,
      carbs: 180,
      fat: 60,
      tags: ['Giữ dáng', 'Gia đình', 'Meal prep'],
      accent: Color(0xFF95E1D3),
    ),
  ];
});

final exploreMealPlansProvider = Provider<List<MealPlan>>((ref) {
  return const [
    MealPlan(
      id: 'explore_plant',
      title: 'Plant Power 1700',
      description: 'Thực đơn thuần chay giàu protein với đậu hũ & đậu lăng.',
      calories: 1700,
      mealsPerDay: 4,
      durationWeeks: 3,
      protein: 110,
      carbs: 200,
      fat: 50,
      tags: ['Thuần chay', 'High protein', 'Siêu thị dễ mua'],
      accent: Color(0xFFF7D9AA),
    ),
    MealPlan(
      id: 'explore_keto',
      title: 'Keto Focus 1600',
      description: 'Tập trung vào chất béo tốt và protein nạc cho ketosis.',
      calories: 1600,
      mealsPerDay: 3,
      durationWeeks: 4,
      protein: 130,
      carbs: 40,
      fat: 95,
      tags: ['Keto', 'Không đường', 'Nấu nhanh'],
      accent: Color(0xFFEDA1C2),
    ),
    MealPlan(
      id: 'explore_runner',
      title: 'Runner Fuel 2200',
      description: 'Nạp năng lượng cho buổi chạy dài với carb thấp GI.',
      calories: 2200,
      mealsPerDay: 5,
      durationWeeks: 8,
      protein: 145,
      carbs: 260,
      fat: 70,
      tags: ['Tập luyện', 'Carb thông minh', 'Sáng + snack'],
      accent: Color(0xFFB8E1FF),
    ),
  ];
});

final customMealPlansProvider = Provider<List<MealPlan>>((ref) {
  return const [
    MealPlan(
      id: 'custom_weekend',
      title: 'Weekend Treat 2000',
      description: 'Thực đơn cuối tuần thư giãn với món Việt & salad nhẹ.',
      calories: 2000,
      mealsPerDay: 3,
      durationWeeks: 1,
      protein: 110,
      carbs: 210,
      fat: 70,
      tags: ['Cuối tuần', 'Gia đình', 'Thưởng thức'],
      accent: Color(0xFFE0C3FC),
    ),
    MealPlan(
      id: 'custom_office',
      title: 'Office Bento 1800',
      description: 'Meal prep 3 ngày với hộp bento tiện lợi mang đi làm.',
      calories: 1800,
      mealsPerDay: 4,
      durationWeeks: 2,
      protein: 125,
      carbs: 170,
      fat: 58,
      tags: ['Mang đi', 'Meal prep', 'Tiết kiệm'],
      accent: Color(0xFFFFF2B2),
    ),
  ];
});

final mealCategoriesProvider = Provider<List<MealCategory>>((ref) {
  return const [
    MealCategory(
      label: 'Giảm mỡ',
      icon: Icons.monitor_weight_outlined,
      accent: AppColors.mintGreen,
    ),
    MealCategory(
      label: 'Tăng cơ',
      icon: Icons.fitness_center_outlined,
      accent: Color(0xFF90CAF9),
    ),
    MealCategory(
      label: 'Thuần chay',
      icon: Icons.eco_outlined,
      accent: Color(0xFFA5D6A7),
    ),
    MealCategory(
      label: 'Meal prep',
      icon: Icons.lunch_dining,
      accent: Color(0xFFFFD54F),
    ),
    MealCategory(
      label: 'Không gluten',
      icon: Icons.spa_outlined,
      accent: Color(0xFFFFAB91),
    ),
  ];
});

