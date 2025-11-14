import 'package:flutter_test/flutter_test.dart';
import 'package:calories_app/features/onboarding/data/services/nutrition_calculator.dart';

void main() {
  group('NutritionCalculator', () {
    group('calcBMI', () {
      test('should calculate BMI correctly for normal values', () {
        final bmi = NutritionCalculator.calcBMI(
          weightKg: 70.0,
          heightM: 1.75,
        );
        expect(bmi, closeTo(22.86, 0.01));
      });

      test('should throw error for zero height', () {
        expect(
          () => NutritionCalculator.calcBMI(weightKg: 70.0, heightM: 0.0),
          throwsArgumentError,
        );
      });

      test('should calculate BMI for edge case - very light', () {
        final bmi = NutritionCalculator.calcBMI(
          weightKg: 40.0,
          heightM: 1.60,
        );
        expect(bmi, closeTo(15.625, 0.01));
      });

      test('should calculate BMI for edge case - very heavy', () {
        final bmi = NutritionCalculator.calcBMI(
          weightKg: 120.0,
          heightM: 1.80,
        );
        expect(bmi, closeTo(37.04, 0.01));
      });
    });

    group('calcBMR', () {
      test('should calculate BMR for male correctly', () {
        final bmr = NutritionCalculator.calcBMR(
          weightKg: 70.0,
          heightCm: 175,
          age: 30,
          gender: 'male',
        );
        // 10 * 70 + 6.25 * 175 - 5 * 30 + 5 = 1648.75
        expect(bmr, closeTo(1648.75, 0.01));
      });

      test('should calculate BMR for female correctly', () {
        final bmr = NutritionCalculator.calcBMR(
          weightKg: 60.0,
          heightCm: 165,
          age: 25,
          gender: 'female',
        );
        // 10 * 60 + 6.25 * 165 - 5 * 25 - 161 = 1345.25
        expect(bmr, closeTo(1345.25, 0.01));
      });

      test('should calculate BMR for Vietnamese male (nam)', () {
        final bmr = NutritionCalculator.calcBMR(
          weightKg: 70.0,
          heightCm: 175,
          age: 30,
          gender: 'nam',
        );
        // 10 * 70 + 6.25 * 175 - 5 * 30 + 5 = 1648.75
        expect(bmr, closeTo(1648.75, 0.01));
      });

      test('should calculate BMR for edge case - young male', () {
        final bmr = NutritionCalculator.calcBMR(
          weightKg: 50.0,
          heightCm: 160,
          age: 18,
          gender: 'male',
        );
        // 10 * 50 + 6.25 * 160 - 5 * 18 + 5 = 1415.0
        expect(bmr, closeTo(1415.0, 0.01));
      });

      test('should calculate BMR for edge case - old female', () {
        final bmr = NutritionCalculator.calcBMR(
          weightKg: 65.0,
          heightCm: 160,
          age: 80,
          gender: 'female',
        );
        // 10 * 65 + 6.25 * 160 - 5 * 80 - 161 = 1089.0
        expect(bmr, closeTo(1089.0, 0.01));
      });
    });

    group('calcTDEE', () {
      test('should calculate TDEE correctly', () {
        final tdee = NutritionCalculator.calcTDEE(1500.0, 1.55);
        expect(tdee, closeTo(2325.0, 0.01));
      });

      test('should calculate TDEE for sedentary', () {
        final tdee = NutritionCalculator.calcTDEE(1500.0, 1.2);
        expect(tdee, 1800.0);
      });

      test('should calculate TDEE for very active', () {
        final tdee = NutritionCalculator.calcTDEE(1500.0, 1.9);
        expect(tdee, 2850.0);
      });
    });

    group('calcDailyDeltaKcal', () {
      test('should calculate daily delta for lose goal', () {
        final delta = NutritionCalculator.calcDailyDeltaKcal(
          weeklyDeltaKg: 0.5,
          goalType: 'lose',
        );
        expect(delta, closeTo(-550.0, 0.01));
      });

      test('should calculate daily delta for gain goal', () {
        final delta = NutritionCalculator.calcDailyDeltaKcal(
          weeklyDeltaKg: 0.5,
          goalType: 'gain',
        );
        expect(delta, closeTo(550.0, 0.01));
      });

      test('should calculate daily delta for edge case - max weekly', () {
        final delta = NutritionCalculator.calcDailyDeltaKcal(
          weeklyDeltaKg: 1.0,
          goalType: 'lose',
        );
        expect(delta, closeTo(-1100.0, 0.01));
      });
    });

    group('calcTargetKcal', () {
      test('should calculate target kcal for maintain', () {
        final target = NutritionCalculator.calcTargetKcal(
          tdee: 2000.0,
          goalType: 'maintain',
        );
        expect(target, 2000.0);
      });

      test('should calculate target kcal for lose goal', () {
        final target = NutritionCalculator.calcTargetKcal(
          tdee: 2000.0,
          goalType: 'lose',
          dailyDeltaKcal: -500.0,
        );
        expect(target, 1500.0);
      });

      test('should calculate target kcal for gain goal', () {
        final target = NutritionCalculator.calcTargetKcal(
          tdee: 2000.0,
          goalType: 'gain',
          dailyDeltaKcal: 500.0,
        );
        expect(target, 2500.0);
      });

      test('should clamp to minimum calories (1200)', () {
        final target = NutritionCalculator.calcTargetKcal(
          tdee: 2000.0,
          goalType: 'lose',
          dailyDeltaKcal: -1000.0,
        );
        expect(target, 1200.0);
      });
    });

    group('calcMacros', () {
      test('should calculate macros correctly with default percentages', () {
        final macros = NutritionCalculator.calcMacros(targetKcal: 2000.0);
        expect(macros['protein'], closeTo(100.0, 0.01)); // 20% of 2000 / 4
        expect(macros['carb'], closeTo(250.0, 0.01)); // 50% of 2000 / 4
        expect(macros['fat'], closeTo(66.67, 0.01)); // 30% of 2000 / 9
      });

      test('should calculate macros with custom percentages', () {
        final macros = NutritionCalculator.calcMacros(
          targetKcal: 2000.0,
          proteinPercent: 30.0,
          carbPercent: 40.0,
          fatPercent: 30.0,
        );
        expect(macros['protein'], closeTo(150.0, 0.01)); // 30% of 2000 / 4
        expect(macros['carb'], closeTo(200.0, 0.01)); // 40% of 2000 / 4
        expect(macros['fat'], closeTo(66.67, 0.01)); // 30% of 2000 / 9
      });
    });

    group('estimateGoalDate', () {
      test('should estimate goal date for lose goal', () {
        final goalDate = NutritionCalculator.estimateGoalDate(
          currentWeight: 80.0,
          targetWeight: 70.0,
          weeklyDeltaKg: 0.5,
        );
        expect(goalDate, isNotNull);
        final weeks = goalDate!.difference(DateTime.now()).inDays ~/ 7;
        // 10 kg / 0.5 kg/week = 20 weeks, but ceil might give 19-20 weeks
        expect(weeks, greaterThanOrEqualTo(19));
        expect(weeks, lessThanOrEqualTo(21));
      });

      test('should estimate goal date for gain goal', () {
        final goalDate = NutritionCalculator.estimateGoalDate(
          currentWeight: 60.0,
          targetWeight: 70.0,
          weeklyDeltaKg: 0.5,
        );
        expect(goalDate, isNotNull);
        final weeks = goalDate!.difference(DateTime.now()).inDays ~/ 7;
        // 10 kg / 0.5 kg/week = 20 weeks, but ceil might give 19-20 weeks
        expect(weeks, greaterThanOrEqualTo(19));
        expect(weeks, lessThanOrEqualTo(21));
      });

      test('should return null for already at goal', () {
        final goalDate = NutritionCalculator.estimateGoalDate(
          currentWeight: 70.0,
          targetWeight: 70.0,
          weeklyDeltaKg: 0.5,
        );
        expect(goalDate, isNull);
      });

      test('should return null for invalid weekly delta', () {
        final goalDate = NutritionCalculator.estimateGoalDate(
          currentWeight: 80.0,
          targetWeight: 70.0,
          weeklyDeltaKg: 0.0,
        );
        expect(goalDate, isNull);
      });
    });
  });
}

