import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeSelectedDateNotifier extends Notifier<DateTime> {
  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  DateTime build() => _normalizeDate(DateTime.now());

  void select(DateTime date) {
    state = _normalizeDate(date);
  }
}

/// Selected date for the home dashboard (defaults to today).
final homeSelectedDateProvider =
    NotifierProvider<HomeSelectedDateNotifier, DateTime>(
  HomeSelectedDateNotifier.new,
);

/// Model representing the user's daily calorie summary.
class DailySummary {
  DailySummary({
    required this.goal,
    required this.consumed,
    required this.burned,
  });

  final double goal;
  final double consumed;
  final double burned;

  double get netIntake => max(consumed - burned, 0);

  double get remaining => max(goal - netIntake, 0);

  double get progress => (netIntake / goal).clamp(0, 1);
}

/// Mock provider for the daily summary.
final homeDailySummaryProvider = Provider<DailySummary>((ref) {
  // TODO: Replace with real data from Firestore / analytics repository.
  return DailySummary(
    goal: 2100,
    consumed: 1450,
    burned: 320,
  );
});

class MacroProgress {
  const MacroProgress({
    required this.label,
    required this.icon,
    required this.unit,
    required this.consumed,
    required this.target,
    required this.color,
  });

  final String label;
  final IconData icon;
  final String unit;
  final double consumed;
  final double target;
  final Color color;

  double get progress => (consumed / target).clamp(0, 1);
}

final homeMacroSummaryProvider = Provider<List<MacroProgress>>((ref) {
  // TODO: Replace with macro breakdown fetched from diary aggregation.
  return const [
    MacroProgress(
      label: 'Chất đạm',
      icon: Icons.egg_alt_outlined,
      unit: 'g',
      consumed: 68,
      target: 110,
      color: Color(0xFF81C784),
    ),
    MacroProgress(
      label: 'Đường bột',
      icon: Icons.rice_bowl_outlined,
      unit: 'g',
      consumed: 190,
      target: 250,
      color: Color(0xFF64B5F6),
    ),
    MacroProgress(
      label: 'Chất béo',
      icon: Icons.bubble_chart_outlined,
      unit: 'g',
      consumed: 55,
      target: 70,
      color: Color(0xFFF48FB1),
    ),
  ];
});

class RecentDiaryEntry {
  const RecentDiaryEntry({
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.timeLabel,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final int calories;
  final String timeLabel;
  final IconData icon;
}

final homeRecentDiaryEntriesProvider =
    Provider<List<RecentDiaryEntry>>((ref) {
  // TODO: Load real recent diary entries from Firestore.
  return const [
    RecentDiaryEntry(
      title: 'Bữa sáng',
      subtitle: 'Yến mạch + sữa hạnh nhân',
      calories: 320,
      timeLabel: '07:30',
      icon: Icons.free_breakfast,
    ),
    RecentDiaryEntry(
      title: 'Bữa trưa',
      subtitle: 'Cơm gạo lứt + ức gà + rau',
      calories: 540,
      timeLabel: '12:15',
      icon: Icons.lunch_dining,
    ),
    RecentDiaryEntry(
      title: 'Bữa phụ',
      subtitle: 'Sữa chua Hy Lạp',
      calories: 150,
      timeLabel: '15:45',
      icon: Icons.icecream,
    ),
  ];
});

class ActivityCategory {
  const ActivityCategory({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

final homeActivityCategoriesProvider = Provider<List<ActivityCategory>>((ref) {
  return const [
    ActivityCategory(label: 'Chạy bộ', icon: Icons.directions_run),
    ActivityCategory(label: 'Đạp xe', icon: Icons.directions_bike),
    ActivityCategory(label: 'Cầu lông', icon: Icons.sports_tennis),
    ActivityCategory(label: 'Yoga', icon: Icons.self_improvement),
    ActivityCategory(label: 'Khác', icon: Icons.fitness_center),
  ];
});

class ActivitySummary {
  const ActivitySummary({
    required this.stepsMessage,
    required this.workoutCalories,
  });

  final String stepsMessage;
  final int workoutCalories;
}

final homeActivitySummaryProvider = Provider<ActivitySummary>((ref) {
  // TODO: Replace with actual integration to steps/workout tracking.
  return const ActivitySummary(
    stepsMessage: 'Kết nối Google Fit để tự động cập nhật',
    workoutCalories: 320,
  );
});

class WaterIntake {
  const WaterIntake({
    required this.totalMl,
    required this.goalMl,
  });

  final int totalMl;
  final int goalMl;

  double get progress => (totalMl / goalMl).clamp(0, 1);
}

final homeWaterIntakeProvider = Provider<WaterIntake>((ref) {
  // TODO: Hook up with water tracking repository (user-defined goal).
  return const WaterIntake(
    totalMl: 1400,
    goalMl: 2200,
  );
});

class WeightPoint {
  const WeightPoint({
    required this.date,
    required this.weight,
  });

  final DateTime date;
  final double weight;
}

class WeightHistory {
  const WeightHistory({
    required this.lastWeight,
    required this.lastUpdated,
    required this.points,
  });

  final double lastWeight;
  final DateTime lastUpdated;
  final List<WeightPoint> points;
}

final homeWeightHistoryProvider = Provider<WeightHistory>((ref) {
  final now = DateTime.now();
  // TODO: Replace with actual weight history fetched from user profile.
  final points = List.generate(7, (index) {
    final date = now.subtract(Duration(days: 6 - index));
    final base = 64.5 + sin(index / 2) * 0.8;
    return WeightPoint(date: date, weight: double.parse(base.toStringAsFixed(1)));
  });
  return WeightHistory(
    lastWeight: 64.9,
    lastUpdated: now.subtract(const Duration(days: 1)),
    points: points,
  );
});

