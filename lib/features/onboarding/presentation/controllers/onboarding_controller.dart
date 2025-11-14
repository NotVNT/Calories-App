import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/utils/units/weight_units.dart';
import 'package:calories_app/features/onboarding/data/services/onboarding_persistence_service.dart';
import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';

/// Onboarding controller notifier (Riverpod v3)
class OnboardingController extends Notifier<OnboardingModel> {
  @override
  OnboardingModel build() {
    // Load draft asynchronously
    _loadDraft();
    return OnboardingModel.empty();
  }

  /// Load draft state from SharedPreferences
  Future<void> _loadDraft() async {
    try {
      final draft = await OnboardingPersistenceService.loadDraft();
      if (draft != null) {
        // Update state without triggering save during load
        state = draft;
      }
    } catch (e) {
      // Silently fail to not break the app
      debugPrint('Failed to load onboarding draft: $e');
    }
  }

  /// Save draft state to SharedPreferences
  Future<void> _saveDraft() async {
    try {
      await OnboardingPersistenceService.saveDraft(state);
    } catch (e) {
      // Silently fail to not break the app
      debugPrint('Failed to save onboarding draft: $e');
    }
  }

  /// Update state and auto-save
  void _updateState(OnboardingModel newState) {
    state = newState;
    // Auto-save on every state change (async, fire and forget)
    _saveDraft();
  }

  /// Update nickname
  void updateNickname(String nickname) {
    _updateState(state.copyWith(nickname: nickname));
  }

  /// Update age and gender
  void updateAgeAndGender(int age, String gender) {
    _updateState(state.copyWith(age: age, gender: gender));
  }

  /// Update gender only
  void updateGender(String gender) {
    _updateState(state.copyWith(gender: gender));
  }

  /// Update height in centimeters
  void updateHeight(int heightCm) {
    // Also update height in meters for BMR calculation
    final heightInMeters = heightCm / 100.0;
    _updateState(state.copyWith(heightCm: heightCm, height: heightInMeters));
  }

  /// Update weight in kilograms and calculate BMI
  /// Accepts double but stores as half-kg internally
  void updateWeight(double weightKg) {
    // Convert to half-kg and clamp
    final weightHalfKg = WeightUnits.clampAndConvert(weightKg);
    
    // Calculate BMI if height is available
    double? bmi;
    final weightKgComputed = WeightUnits.fromHalfKg(weightHalfKg);
    if (state.heightCm != null) {
      final heightInMeters = state.heightCm! / 100.0;
      bmi = weightKgComputed / (heightInMeters * heightInMeters);
    } else if (state.height != null) {
      bmi = weightKgComputed / (state.height! * state.height!);
    }

    // Store as half-kg internally, keep weightKg for backward compatibility during migration
    _updateState(state.copyWith(
      weightHalfKg: weightHalfKg,
      weightKg: weightKgComputed, // Keep for backward compatibility
      weight: weightKgComputed,
      bmi: bmi,
    ));
  }

  /// Update height and weight
  void updateHeightAndWeight(double height, double weight) {
    _updateState(state.copyWith(height: height, weight: weight));
  }

  /// Update goal type
  void updateGoalType(String goalType) {
    _updateState(state.copyWith(goalType: goalType));
  }

  /// Update target weight
  /// Accepts double but stores as half-kg internally
  void updateTargetWeight(double targetWeight) {
    // Convert to half-kg and clamp
    final targetWeightHalfKg = WeightUnits.clampAndConvert(targetWeight);
    final targetWeightComputed = WeightUnits.fromHalfKg(targetWeightHalfKg);
    
    // Store as half-kg internally, keep targetWeight for backward compatibility
    _updateState(state.copyWith(
      targetWeightHalfKg: targetWeightHalfKg,
      targetWeight: targetWeightComputed, // Keep for backward compatibility
    ));
  }

  /// Update weekly delta (weight change per week)
  void updateWeeklyDelta(double weeklyDeltaKg) {
    _updateState(state.copyWith(weeklyDeltaKg: weeklyDeltaKg));
  }

  /// Update activity level and multiplier
  void updateActivityLevel(String activityLevel, double multiplier) {
    _updateState(state.copyWith(
      activityLevel: activityLevel,
      activityMultiplier: multiplier,
    ));
  }

  /// Update date of birth and compute age
  void updateDob(DateTime dob) {
    final normalizedDob = DateTime(dob.year, dob.month, dob.day);
    final age = _calculateAge(normalizedDob);
    _updateState(state.copyWith(
      dobIso: normalizedDob.toIso8601String(),
      age: age,
    ));
  }

  /// Update target calories
  void updateTargetKcal(double targetKcal) {
    _updateState(state.copyWith(targetKcal: targetKcal));
  }

  /// Update BMR and TDEE (calculated values)
  void updateBMRAndTDEE(double bmr, double tdee) {
    _updateState(state.copyWith(bmr: bmr, tdee: tdee));
  }

  /// Update macros
  void updateMacros({
    required double proteinPercent,
    required double carbPercent,
    required double fatPercent,
  }) {
    _updateState(state.copyWith(
      proteinPercent: proteinPercent,
      carbPercent: carbPercent,
      fatPercent: fatPercent,
    ));
  }

  /// Calculate BMR using Mifflin-St Jeor Equation
  void calculateBMR() {
    if (state.age == null ||
        state.gender == null) {
      return;
    }

    // Use weightKgComputed (from half-kg if available, else weightKg)
    final weight = state.weightKgComputed;
    if (weight == null) {
      return;
    }

    // Use heightCm if available, otherwise use height (in meters)
    double heightInMeters;
    if (state.heightCm != null) {
      heightInMeters = state.heightCm! / 100.0;
    } else if (state.height != null) {
      heightInMeters = state.height!;
    } else {
      return;
    }

    final age = state.age!;
    final gender = state.gender!;

    double bmr;
    // Height should be in cm for the formula
    final heightInCm = heightInMeters * 100;
    if (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'nam') {
      bmr = 10 * weight + 6.25 * heightInCm - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * heightInCm - 5 * age - 161;
    }

    state = state.copyWith(bmr: bmr);
  }

  /// Calculate TDEE based on activity level
  void calculateTDEE() {
    if (state.bmr == null) {
      return;
    }

    final bmr = state.bmr!;
    
    // Use activityMultiplier if available, otherwise calculate from activityLevel
    double multiplier;
    if (state.activityMultiplier != null) {
      multiplier = state.activityMultiplier!;
    } else if (state.activityLevel != null) {
      final activityLevel = state.activityLevel!;
      switch (activityLevel.toLowerCase()) {
        case 'sedentary':
        case 'ít vận động':
          multiplier = 1.2;
          break;
        case 'light':
        case 'nhẹ':
          multiplier = 1.375;
          break;
        case 'moderate':
        case 'vừa phải':
          multiplier = 1.55;
          break;
        case 'active':
        case 'năng động':
          multiplier = 1.725;
          break;
        case 'very active':
        case 'rất năng động':
        case 'extra':
          multiplier = 1.9;
          break;
        default:
          multiplier = 1.2;
      }
    } else {
      return;
    }

    final tdee = bmr * multiplier;
    _updateState(state.copyWith(tdee: tdee));
  }

  /// Save calculated nutrition result
  void saveResult(Map<String, dynamic> result) {
    _updateState(state.copyWith(result: result));
  }

  /// Reset onboarding data
  void reset() {
    state = OnboardingModel.empty();
    // Clear draft when resetting
    OnboardingPersistenceService.clearDraft();
  }

  /// Get current step index (0-based)
  int get currentStep => state.currentStep;

  /// Check if current step is valid
  bool isCurrentStepValid() {
    return state.isStepValid(currentStep);
  }

  /// Check if can go to next step
  bool canGoNext() {
    return isCurrentStepValid() && currentStep < OnboardingModel.totalSteps - 1;
  }

  /// Check if can go to previous step
  bool canGoBack() {
    return currentStep > 0;
  }

  /// Go to next step (if valid)
  bool nextStep() {
    if (!canGoNext()) return false;
    // Step navigation is handled by screens
    return true;
  }

  /// Go to previous step
  bool previousStep() {
    if (!canGoBack()) return false;
    // Step navigation is handled by screens
    return true;
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    final hasNotHadBirthday =
        today.month < dob.month || (today.month == dob.month && today.day < dob.day);
    if (hasNotHadBirthday) {
      age--;
    }
    return age;
  }
}

/// Onboarding controller provider (Riverpod v3)
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingModel>(() {
  return OnboardingController();
});

