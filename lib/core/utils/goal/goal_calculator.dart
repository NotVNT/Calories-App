/// Input model for BMR calculation
class BmrInputs {
  final double weightKg;
  final int heightCm;
  final int age;
  final String gender; // 'male' or 'female'

  const BmrInputs({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
  });
}

/// Input model for goal calculation
class GoalInputs {
  final double bmr;
  final double tdee;
  final String goalType; // 'lose', 'gain', 'maintain'
  final double? paceKgPerWeek; // Optional, will use safe defaults if null
  final String gender;

  const GoalInputs({
    required this.bmr,
    required this.tdee,
    required this.goalType,
    this.paceKgPerWeek,
    required this.gender,
  });
}

/// Result model with all calculated values
class GoalResult {
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double deficitOrSurplus; // Positive = deficit, Negative = surplus
  final double paceKgPerWeek;
  final int etaWeeks; // 0 for maintain
  final int proteinGrams;
  final int fatGrams;
  final int carbGrams;
  final int proteinPercent;
  final int fatPercent;
  final int carbPercent;
  final double bmiCurrent;
  final double? bmiTarget;
  final List<String> warnings; // Safety warnings if values were clamped

  const GoalResult({
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.deficitOrSurplus,
    required this.paceKgPerWeek,
    required this.etaWeeks,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbGrams,
    required this.proteinPercent,
    required this.fatPercent,
    required this.carbPercent,
    required this.bmiCurrent,
    this.bmiTarget,
    this.warnings = const [],
  });
}

/// Goal calculator service with safety bounds and business logic
/// Pure Dart service for calculating BMR, TDEE, target calories, macros, and ETA
class GoalCalculator {
  // Constants
  static const double kcalPerKg = 7700.0; // 1 kg ≈ 7700 kcal
  static const double kcalPerDayPerWeek = kcalPerKg / 7.0; // ~1100 kcal/day per 1 kg/week

  // Safety bounds
  static const double minDeficitKcal = 300.0;
  static const double maxDeficitKcal = 1000.0;
  static const double preferredMinDeficitKcal = 500.0;
  static const double preferredMaxDeficitKcal = 750.0;

  static const double minSurplusKcal = 150.0;
  static const double maxSurplusKcal = 600.0;
  static const double preferredMinSurplusKcal = 250.0;
  static const double preferredMaxSurplusKcal = 500.0;

  static const double minCaloriesFemale = 1200.0;
  static const double minCaloriesMale = 1500.0;
  static const double maxBulkingMultiplier = 2.2;
  static const double minBmrMultiplier = 1.1;
  static const double maxBulkingSurplusKcal = 700.0;

  // BMI thresholds
  static const double minHealthyBmi = 18.5;
  static const double maxHealthyBmi = 27.5;

  /// Calculate BMR using Mifflin-St Jeor Equation
  /// male: 10W + 6.25H − 5A + 5
  /// female: 10W + 6.25H − 5A − 161
  static double calculateBMR(BmrInputs inputs) {
    final isMale = inputs.gender.toLowerCase() == 'male' || 
                   inputs.gender.toLowerCase() == 'nam';
    
    if (isMale) {
      return 10 * inputs.weightKg + 6.25 * inputs.heightCm - 5 * inputs.age + 5;
    } else {
      return 10 * inputs.weightKg + 6.25 * inputs.heightCm - 5 * inputs.age - 161;
    }
  }

  /// Calculate TDEE: BMR × activity multiplier
  static double calculateTDEE(double bmr, double activityMultiplier) {
    return bmr * activityMultiplier;
  }

  /// Get safe default pace based on goal type
  static double getSafeDefaultPace(String goalType) {
    switch (goalType) {
      case 'lose':
        return 0.5; // 0.5 kg/week (middle of 0.25-0.75 range)
      case 'gain':
        return 0.25; // 0.25 kg/week (middle of 0.15-0.35 range)
      case 'maintain':
      default:
        return 0.0;
    }
  }

  /// Calculate daily delta kcal from weekly pace
  static double calculateDailyDeltaKcal(double paceKgPerWeek, String goalType) {
    if (goalType == 'maintain' || paceKgPerWeek <= 0) {
      return 0.0;
    }
    final dailyDelta = paceKgPerWeek * kcalPerDayPerWeek;
    return goalType == 'lose' ? -dailyDelta : dailyDelta;
  }

  /// Clamp deficit/surplus to safety bounds
  static double clampDeficitOrSurplus(
    double deltaKcal,
    String goalType,
    double bmr,
    String gender,
  ) {
    if (goalType == 'maintain') return 0.0;
    
    if (goalType == 'lose') {
      // Deficit: positive value, clamp to 300-1000 range
      final deficit = deltaKcal.abs();
      if (deficit < minDeficitKcal) {
        return -minDeficitKcal; // Return negative for deficit
      } else if (deficit > maxDeficitKcal) {
        return -maxDeficitKcal;
      }
      return -deficit; // Negative for deficit
    } else {
      // Surplus: positive value, clamp to 150-600 range
      final surplus = deltaKcal.abs();
      if (surplus < minSurplusKcal) {
        return minSurplusKcal;
      } else if (surplus > maxSurplusKcal) {
        return maxSurplusKcal;
      }
      return surplus;
    }
  }

  /// Calculate minimum safe calories
  static double calculateMinCalories(double bmr, String gender) {
    final isMale = gender.toLowerCase() == 'male' || 
                   gender.toLowerCase() == 'nam';
    final minByBmr = bmr * minBmrMultiplier;
    final minByGender = isMale ? minCaloriesMale : minCaloriesFemale;
    return minByBmr > minByGender ? minByBmr : minByGender;
  }

  /// Calculate maximum safe calories for bulking
  static double calculateMaxCalories(double bmr, double tdee) {
    final maxByBmr = bmr * maxBulkingMultiplier;
    final maxByTdee = tdee + maxBulkingSurplusKcal;
    return maxByBmr < maxByTdee ? maxByBmr : maxByTdee;
  }

  /// Calculate target calories with safety bounds
  static double calculateTargetCalories(
    double tdee,
    double deltaKcalPerDay,
    String goalType,
    double bmr,
    String gender,
  ) {
    double target;
    
    if (goalType == 'maintain') {
      target = tdee;
    } else {
      target = tdee + deltaKcalPerDay; // deltaKcalPerDay is negative for lose
    }

    // Clamp to minimum safe calories
    final minCal = calculateMinCalories(bmr, gender);
    if (target < minCal) {
      return minCal;
    }

    // Clamp to maximum safe calories for bulking
    if (goalType == 'gain') {
      final maxCal = calculateMaxCalories(bmr, tdee);
      if (target > maxCal) {
        return maxCal;
      }
    }

    return target;
  }

  /// Calculate macros based on goal type
  static Map<String, double> calculateMacros(
    double targetCalories,
    double weightKg,
    String goalType,
  ) {
    // Protein: 2.0 g/kg for cut, 1.8 g/kg for bulk
    final proteinGramsPerKg = goalType == 'lose' ? 2.0 : 1.8;
    final proteinGrams = weightKg * proteinGramsPerKg;
    final proteinKcal = proteinGrams * 4.0;

    // Fat: 27% for cut, 30% for bulk
    final fatPercent = goalType == 'lose' ? 0.27 : 0.30;
    final fatKcal = targetCalories * fatPercent;
    final fatGrams = fatKcal / 9.0;

    // Carbs: remaining calories
    final remainingKcal = targetCalories - proteinKcal - fatKcal;
    final carbGrams = remainingKcal / 4.0;

    // Clamp to non-negative
    final clampedProtein = proteinGrams < 0 ? 0.0 : proteinGrams;
    final clampedFat = fatGrams < 0 ? 0.0 : fatGrams;
    final clampedCarb = carbGrams < 0 ? 0.0 : carbGrams;

    return {
      'protein': clampedProtein,
      'fat': clampedFat,
      'carb': clampedCarb,
    };
  }

  /// Calculate BMI
  static double calculateBMI(double weightKg, int heightCm) {
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  /// Calculate ETA weeks
  static int calculateETAWeeks(
    double currentWeightKg,
    double? targetWeightKg,
    double paceKgPerWeek,
    String goalType,
  ) {
    if (goalType == 'maintain' || targetWeightKg == null || paceKgPerWeek <= 0) {
      return 0;
    }
    final weightDiff = (targetWeightKg - currentWeightKg).abs();
    if (weightDiff < 0.1) {
      return 0;
    }
    return (weightDiff / paceKgPerWeek).ceil();
  }

  /// Main calculation method
  static GoalResult calculate({
    required BmrInputs bmrInputs,
    required GoalInputs goalInputs,
    required double currentWeightKg,
    required int heightCm,
    double? targetWeightKg,
  }) {
    // Calculate BMR (if not provided, recalculate)
    final bmr = goalInputs.bmr > 0 ? goalInputs.bmr : calculateBMR(bmrInputs);
    
    // Calculate TDEE (if not provided, recalculate)
    final tdee = goalInputs.tdee > 0 ? goalInputs.tdee : calculateTDEE(bmr, 1.2);

    // Get pace (use provided or safe default)
    final paceKgPerWeek = goalInputs.paceKgPerWeek ?? 
                          getSafeDefaultPace(goalInputs.goalType);

    // Calculate daily delta
    var dailyDeltaKcal = calculateDailyDeltaKcal(paceKgPerWeek, goalInputs.goalType);
    
    // Clamp deficit/surplus to safety bounds
    final clampedDelta = clampDeficitOrSurplus(
      dailyDeltaKcal,
      goalInputs.goalType,
      bmr,
      goalInputs.gender,
    );
    
    final warnings = <String>[];
    if (clampedDelta != dailyDeltaKcal) {
      warnings.add('Điều chỉnh tốc độ để đảm bảo an toàn');
    }

    // Calculate target calories with safety bounds
    final targetCalories = calculateTargetCalories(
      tdee,
      clampedDelta,
      goalInputs.goalType,
      bmr,
      goalInputs.gender,
    );

    // Check if target calories were clamped
    final expectedTarget = goalInputs.goalType == 'maintain' 
        ? tdee 
        : tdee + clampedDelta;
    if ((targetCalories - expectedTarget).abs() > 1.0) {
      warnings.add('Lượng calo mục tiêu đã được điều chỉnh để đảm bảo an toàn');
    }

    // Calculate macros
    final macros = calculateMacros(targetCalories, currentWeightKg, goalInputs.goalType);
    
    // Calculate percentages
    final totalKcal = macros['protein']! * 4 + 
                      macros['fat']! * 9 + 
                      macros['carb']! * 4;
    final proteinPercent = totalKcal > 0 
        ? ((macros['protein']! * 4 / totalKcal) * 100).round()
        : 0;
    final fatPercent = totalKcal > 0 
        ? ((macros['fat']! * 9 / totalKcal) * 100).round()
        : 0;
    final carbPercent = totalKcal > 0 
        ? ((macros['carb']! * 4 / totalKcal) * 100).round()
        : 0;

    // Calculate BMI
    final bmiCurrent = calculateBMI(currentWeightKg, heightCm);
    final bmiTarget = targetWeightKg != null 
        ? calculateBMI(targetWeightKg, heightCm)
        : null;

    // Calculate ETA
    final etaWeeks = calculateETAWeeks(
      currentWeightKg,
      targetWeightKg,
      paceKgPerWeek,
      goalInputs.goalType,
    );

    return GoalResult(
      bmr: bmr,
      tdee: tdee,
      targetCalories: targetCalories,
      deficitOrSurplus: clampedDelta,
      paceKgPerWeek: paceKgPerWeek,
      etaWeeks: etaWeeks,
      proteinGrams: macros['protein']!.round(),
      fatGrams: macros['fat']!.round(),
      carbGrams: macros['carb']!.round(),
      proteinPercent: proteinPercent,
      fatPercent: fatPercent,
      carbPercent: carbPercent,
      bmiCurrent: bmiCurrent,
      bmiTarget: bmiTarget,
      warnings: warnings,
    );
  }
}

