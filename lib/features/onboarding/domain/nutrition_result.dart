/// Nutrition calculation result
class NutritionResult {
  final double bmr;
  final double tdee;
  final double targetKcal;
  final double proteinPercent;
  final double carbPercent;
  final double fatPercent;
  final double proteinGrams;
  final double carbGrams;
  final double fatGrams;
  final DateTime? goalDate;

  const NutritionResult({
    required this.bmr,
    required this.tdee,
    required this.targetKcal,
    required this.proteinPercent,
    required this.carbPercent,
    required this.fatPercent,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    this.goalDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'bmr': bmr,
      'tdee': tdee,
      'targetKcal': targetKcal,
      'proteinPercent': proteinPercent,
      'carbPercent': carbPercent,
      'fatPercent': fatPercent,
      'proteinGrams': proteinGrams,
      'carbGrams': carbGrams,
      'fatGrams': fatGrams,
      'goalDate': goalDate?.toIso8601String(),
    };
  }

  factory NutritionResult.fromMap(Map<String, dynamic> map) {
    return NutritionResult(
      bmr: map['bmr']?.toDouble() ?? 0.0,
      tdee: map['tdee']?.toDouble() ?? 0.0,
      targetKcal: map['targetKcal']?.toDouble() ?? 0.0,
      proteinPercent: map['proteinPercent']?.toDouble() ?? 0.0,
      carbPercent: map['carbPercent']?.toDouble() ?? 0.0,
      fatPercent: map['fatPercent']?.toDouble() ?? 0.0,
      proteinGrams: map['proteinGrams']?.toDouble() ?? 0.0,
      carbGrams: map['carbGrams']?.toDouble() ?? 0.0,
      fatGrams: map['fatGrams']?.toDouble() ?? 0.0,
      goalDate: map['goalDate'] != null
          ? DateTime.tryParse(map['goalDate'])
          : null,
    );
  }
}

