import 'package:calories_app/features/onboarding/domain/nutrition_result.dart';
import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';

/// Nutrition calculator service
class NutritionCalculator {
  // Calories per gram
  static const double calPerGramProtein = 4.0;
  static const double calPerGramCarb = 4.0;
  static const double calPerGramFat = 9.0;

  // Default macros percentages
  static const double defaultProteinPercent = 20.0;
  static const double defaultCarbPercent = 50.0;
  static const double defaultFatPercent = 30.0;

  // Safety minimum calories
  static const double minCalories = 1200.0;

  /// Calculate BMI: weight (kg) / height (m)^2
  static double calcBMI({
    required double weightKg,
    required double heightM,
  }) {
    if (heightM <= 0) {
      throw ArgumentError('Height must be greater than 0');
    }
    return weightKg / (heightM * heightM);
  }

  /// Calculate BMR using Mifflin-St Jeor Equation
  /// male: 10W + 6.25H − 5A + 5
  /// female: 10W + 6.25H − 5A − 161
  static double calcBMR({
    required double weightKg,
    required int heightCm,
    required int age,
    required String gender,
  }) {
    final heightInCm = heightCm.toDouble();
    
    if (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'nam') {
      return 10 * weightKg + 6.25 * heightInCm - 5 * age + 5;
    } else {
      return 10 * weightKg + 6.25 * heightInCm - 5 * age - 161;
    }
  }

  /// Calculate TDEE: BMR × multiplier
  static double calcTDEE(double bmr, double multiplier) {
    return bmr * multiplier;
  }

  /// Calculate daily delta kcal from weekly delta
  /// dailyDeltaKcal = weeklyDeltaKg * 7700 / 7
  /// Negative if losing weight
  static double calcDailyDeltaKcal({
    required double weeklyDeltaKg,
    required String goalType,
  }) {
    final dailyDelta = weeklyDeltaKg * 7700 / 7;
    return goalType == 'lose' ? -dailyDelta : dailyDelta;
  }

  /// Calculate target calories
  /// maintain: TDEE
  /// lose/gain: TDEE −/+ dailyDeltaKcal, clamp min 1200
  static double calcTargetKcal({
    required double tdee,
    required String goalType,
    double? dailyDeltaKcal,
  }) {
    double targetKcal;
    
    if (goalType == 'maintain') {
      targetKcal = tdee;
    } else if (dailyDeltaKcal != null) {
      targetKcal = tdee + dailyDeltaKcal; // dailyDeltaKcal is already negative for lose
    } else {
      targetKcal = tdee;
    }

    // Clamp to minimum safety value
    return targetKcal < minCalories ? minCalories : targetKcal;
  }

  /// Calculate macros in grams
  /// grams = (pct * kcal) / calPerGram
  static Map<String, double> calcMacros({
    required double targetKcal,
    double proteinPercent = defaultProteinPercent,
    double carbPercent = defaultCarbPercent,
    double fatPercent = defaultFatPercent,
  }) {
    return {
      'protein': (proteinPercent / 100 * targetKcal) / calPerGramProtein,
      'carb': (carbPercent / 100 * targetKcal) / calPerGramCarb,
      'fat': (fatPercent / 100 * targetKcal) / calPerGramFat,
    };
  }

  /// Estimate goal date
  /// abs(weightDiff) / weeklyDeltaKg → today + weeks
  static DateTime? estimateGoalDate({
    required double currentWeight,
    required double targetWeight,
    required double weeklyDeltaKg,
  }) {
    final weightDiff = (targetWeight - currentWeight).abs();
    if (weightDiff < 0.1 || weeklyDeltaKg <= 0) {
      return null; // Already at goal or invalid delta
    }

    final weeks = (weightDiff / weeklyDeltaKg).ceil();
    return DateTime.now().add(Duration(days: weeks * 7));
  }

  /// Calculate all nutrition values from onboarding model
  static NutritionResult calculateAll(OnboardingModel model) {
    // Validate required fields
    if (model.weightKg == null ||
        model.heightCm == null ||
        model.age == null ||
        model.gender == null ||
        model.activityMultiplier == null) {
      throw Exception('Missing required fields for calculation');
    }

    // Calculate BMR
    final bmr = calcBMR(
      weightKg: model.weightKg!,
      heightCm: model.heightCm!,
      age: model.age!,
      gender: model.gender!,
    );

    // Calculate TDEE
    final tdee = calcTDEE(bmr, model.activityMultiplier!);

    // Calculate daily delta kcal (if applicable)
    double? dailyDeltaKcal;
    if (model.goalType != 'maintain' && model.weeklyDeltaKg != null) {
      dailyDeltaKcal = calcDailyDeltaKcal(
        weeklyDeltaKg: model.weeklyDeltaKg!,
        goalType: model.goalType!,
      );
    }

    // Calculate target calories
    final targetKcal = calcTargetKcal(
      tdee: tdee,
      goalType: model.goalType ?? 'maintain',
      dailyDeltaKcal: dailyDeltaKcal,
    );

    // Use provided macros or defaults
    final proteinPercent = model.proteinPercent ?? defaultProteinPercent;
    final carbPercent = model.carbPercent ?? defaultCarbPercent;
    final fatPercent = model.fatPercent ?? defaultFatPercent;

    // Calculate macros in grams
    final macros = calcMacros(
      targetKcal: targetKcal,
      proteinPercent: proteinPercent,
      carbPercent: carbPercent,
      fatPercent: fatPercent,
    );

    // Estimate goal date
    DateTime? goalDate;
    if (model.weightKg != null &&
        model.targetWeight != null &&
        model.weeklyDeltaKg != null &&
        model.goalType != 'maintain') {
      goalDate = estimateGoalDate(
        currentWeight: model.weightKg!,
        targetWeight: model.targetWeight!,
        weeklyDeltaKg: model.weeklyDeltaKg!,
      );
    }

    return NutritionResult(
      bmr: bmr,
      tdee: tdee,
      targetKcal: targetKcal,
      proteinPercent: proteinPercent,
      carbPercent: carbPercent,
      fatPercent: fatPercent,
      proteinGrams: macros['protein']!,
      carbGrams: macros['carb']!,
      fatGrams: macros['fat']!,
      goalDate: goalDate,
    );
  }
}

