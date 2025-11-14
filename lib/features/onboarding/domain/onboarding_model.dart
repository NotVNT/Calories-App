import 'package:calories_app/core/utils/units/weight_units.dart';

/// Onboarding data model
class OnboardingModel {
  final String? nickname;
  final int? age;
  final String? dobIso;
  final String? gender;
  final double? height;
  final int? heightCm; // Height in centimeters (120-220)
  final double? weight;
  final double? weightKg; // Weight in kilograms (35-200) - DEPRECATED: use weightHalfKg
  final int? weightHalfKg; // Weight in half-kilogram units (70-400, representing 35.0-200.0 kg)
  final double? bmi; // Body Mass Index
  final String? goalType; // lose|maintain|gain
  final double? targetWeight; // Target weight in kilograms - DEPRECATED: use targetWeightHalfKg
  final int? targetWeightHalfKg; // Target weight in half-kilogram units
  final double? weeklyDeltaKg; // Weekly weight change goal (0.25-1.0 kg/week)
  final String? activityLevel;
  final double? activityMultiplier; // BMR multiplier (1.2, 1.375, 1.55, 1.725, 1.9)
  final double? bmr;
  final double? tdee;
  final double? targetKcal;
  final double? proteinPercent;
  final double? carbPercent;
  final double? fatPercent;
  final Map<String, dynamic>? result; // Calculated nutrition result

  const OnboardingModel({
    this.nickname,
    this.age,
    this.gender,
    this.dobIso,
    this.height,
    this.heightCm,
    this.weight,
    this.weightKg,
    this.weightHalfKg,
    this.bmi,
    this.goalType,
    this.targetWeight,
    this.targetWeightHalfKg,
    this.weeklyDeltaKg,
    this.activityLevel,
    this.activityMultiplier,
    this.bmr,
    this.tdee,
    this.targetKcal,
    this.proteinPercent,
    this.carbPercent,
    this.fatPercent,
    this.result,
  });

  /// Get weight in kg (computed from weightHalfKg if available, else weightKg)
  double? get weightKgComputed {
    if (weightHalfKg != null) {
      return WeightUnits.fromHalfKg(weightHalfKg!);
    }
    return weightKg;
  }

  /// Get target weight in kg (computed from targetWeightHalfKg if available, else targetWeight)
  double? get targetWeightComputed {
    if (targetWeightHalfKg != null) {
      return WeightUnits.fromHalfKg(targetWeightHalfKg!);
    }
    return targetWeight;
  }

  /// Create empty onboarding model
  factory OnboardingModel.empty() {
    return const OnboardingModel();
  }

  /// Copy with method
  OnboardingModel copyWith({
    String? nickname,
    int? age,
    String? dobIso,
    String? gender,
    double? height,
    int? heightCm,
    double? weight,
    double? weightKg,
    int? weightHalfKg,
    double? bmi,
    String? goalType,
    double? targetWeight,
    int? targetWeightHalfKg,
    double? weeklyDeltaKg,
    String? activityLevel,
    double? activityMultiplier,
    double? bmr,
    double? tdee,
    double? targetKcal,
    double? proteinPercent,
    double? carbPercent,
    double? fatPercent,
    Map<String, dynamic>? result,
  }) {
    return OnboardingModel(
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      dobIso: dobIso ?? this.dobIso,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      heightCm: heightCm ?? this.heightCm,
      weight: weight ?? this.weight,
      weightKg: weightKg ?? this.weightKg,
      weightHalfKg: weightHalfKg ?? this.weightHalfKg,
      bmi: bmi ?? this.bmi,
      goalType: goalType ?? this.goalType,
      targetWeight: targetWeight ?? this.targetWeight,
      targetWeightHalfKg: targetWeightHalfKg ?? this.targetWeightHalfKg,
      weeklyDeltaKg: weeklyDeltaKg ?? this.weeklyDeltaKg,
      activityLevel: activityLevel ?? this.activityLevel,
      activityMultiplier: activityMultiplier ?? this.activityMultiplier,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      targetKcal: targetKcal ?? this.targetKcal,
      proteinPercent: proteinPercent ?? this.proteinPercent,
      carbPercent: carbPercent ?? this.carbPercent,
      fatPercent: fatPercent ?? this.fatPercent,
      result: result ?? this.result,
    );
  }

  static const int totalSteps = 11;

  bool get _isNicknameValid => nickname != null && nickname!.trim().isNotEmpty;

  bool get _isGenderValid =>
      gender != null && (gender == 'male' || gender == 'female');

  bool get _isAgeValid {
    if (age == null) return false;
    if (age! < 10 || age! > 100) return false;
    return dobIso != null && dobIso!.isNotEmpty;
  }

  bool get _isHeightValid => heightCm != null && heightCm! >= 120 && heightCm! <= 220;

  bool get _isWeightValid {
    final weight = weightKgComputed;
    return weight != null && weight >= 35 && weight <= 200;
  }

  bool get _isGoalTypeValid =>
      goalType != null && (goalType == 'lose' || goalType == 'maintain' || goalType == 'gain');

  bool get _isTargetWeightValid {
    final target = targetWeightComputed;
    final current = weightKgComputed;
    if (target == null || current == null || goalType == null) {
      return false;
    }
    switch (goalType) {
      case 'lose':
        return target < current;
      case 'gain':
        return target > current;
      case 'maintain':
        return (target - current).abs() <= 0.5;
      default:
        return false;
    }
  }

  bool get _isWeeklyDeltaValid {
    // For maintain goal, weekly delta is not required (skip step)
    if (goalType == 'maintain') {
      return true;
    }
    // For lose/gain, weekly delta must be set and in valid range
    return weeklyDeltaKg != null && weeklyDeltaKg! >= 0.25 && weeklyDeltaKg! <= 1.0;
  }

  bool get _isBodyMetricsValid {
    final weight = weightKgComputed;
    return heightCm != null &&
        weight != null &&
        heightCm! >= 120 &&
        heightCm! <= 220 &&
        weight >= 35 &&
        weight <= 200;
  }

  bool get _isActivityValid =>
      activityLevel != null &&
      activityLevel!.trim().isNotEmpty &&
      activityMultiplier != null &&
      activityMultiplier! > 0;

  bool get _isTargetValid => targetKcal != null && targetKcal! > 0;

  bool get _isMacroValid {
    if (proteinPercent == null || carbPercent == null || fatPercent == null) {
      return false;
    }
    final total = proteinPercent! + carbPercent! + fatPercent!;
    return total >= 99 && total <= 101; // ±1% tolerance
  }

  /// Get current progress step (0-6)
  int get currentStep {
    if (!_isNicknameValid) return 0;
    if (!_isGenderValid) return 1;
    if (!_isAgeValid) return 2;
    if (!_isHeightValid) return 3;
    if (!_isWeightValid) return 4;
    if (!_isBodyMetricsValid) return 5;
    if (!_isGoalTypeValid) return 6;
    if (!_isTargetWeightValid) return 7;
    if (!_isWeeklyDeltaValid) return 8;
    if (!_isActivityValid) return 9;
    if (!_isTargetValid) return 10;
    if (!_isMacroValid) return 11;
    return totalSteps; // All steps complete
  }

  /// Get progress percentage (0.0 - 1.0)
  double get progress {
    final step = currentStep.clamp(0, totalSteps);
    return step / totalSteps;
  }

  /// Check if current step is valid
  bool isStepValid(int step) {
    switch (step) {
      case 0:
        return _isNicknameValid;
      case 1:
        return _isGenderValid;
      case 2:
        return _isAgeValid;
      case 3:
        return _isHeightValid;
      case 4:
        return _isWeightValid;
      case 5:
        return _isBodyMetricsValid;
      case 6:
        return _isGoalTypeValid;
      case 7:
        return _isTargetWeightValid;
      case 8:
        return _isWeeklyDeltaValid;
      case 9:
        return _isActivityValid;
      case 10:
        return _isTargetValid;
      case 11:
        return _isMacroValid;
      default:
        return false;
    }
  }
}

