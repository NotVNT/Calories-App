import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';

/// Service to persist onboarding state in SharedPreferences
class OnboardingPersistenceService {
  static const String _keyOnboardingDraft = 'onboarding_draft';
  static const String _keyLastStep = 'onboarding_last_step';

  /// Save onboarding draft state
  static Future<void> saveDraft(OnboardingModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert model to JSON
      final json = _modelToJson(model);
      final jsonString = jsonEncode(json);
      
      // Save to SharedPreferences
      await prefs.setString(_keyOnboardingDraft, jsonString);
      
      // Save last step
      await prefs.setInt(_keyLastStep, model.currentStep);
    } catch (e) {
      // Silently fail to not break the app
      debugPrint('Failed to save onboarding draft: $e');
    }
  }

  /// Load onboarding draft state
  static Future<OnboardingModel?> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyOnboardingDraft);
      
      if (jsonString == null) {
        return null;
      }
      
      // Parse JSON
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Convert to model
      return _jsonToModel(json);
    } catch (e) {
      debugPrint('Failed to load onboarding draft: $e');
      return null;
    }
  }

  /// Get last step index
  static Future<int?> getLastStep() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyLastStep);
    } catch (e) {
      debugPrint('Failed to get last step: $e');
      return null;
    }
  }

  /// Clear onboarding draft
  static Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyOnboardingDraft);
      await prefs.remove(_keyLastStep);
    } catch (e) {
      debugPrint('Failed to clear onboarding draft: $e');
    }
  }

  /// Convert OnboardingModel to JSON map
  static Map<String, dynamic> _modelToJson(OnboardingModel model) {
    return {
      'nickname': model.nickname,
      'age': model.age,
      'dobIso': model.dobIso,
      'gender': model.gender,
      'height': model.height,
      'heightCm': model.heightCm,
      'weight': model.weight,
      'weightKg': model.weightKg,
      'bmi': model.bmi,
      'goalType': model.goalType,
      'targetWeight': model.targetWeight,
      'weeklyDeltaKg': model.weeklyDeltaKg,
      'activityLevel': model.activityLevel,
      'activityMultiplier': model.activityMultiplier,
      'bmr': model.bmr,
      'tdee': model.tdee,
      'targetKcal': model.targetKcal,
      'proteinPercent': model.proteinPercent,
      'carbPercent': model.carbPercent,
      'fatPercent': model.fatPercent,
      'result': model.result,
    };
  }

  /// Convert JSON map to OnboardingModel
  static OnboardingModel _jsonToModel(Map<String, dynamic> json) {
    return OnboardingModel(
      nickname: json['nickname'] as String?,
      age: json['age'] as int?,
      dobIso: json['dobIso'] as String?,
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      heightCm: json['heightCm'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      goalType: json['goalType'] as String?,
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      weeklyDeltaKg: (json['weeklyDeltaKg'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] as String?,
      activityMultiplier: (json['activityMultiplier'] as num?)?.toDouble(),
      bmr: (json['bmr'] as num?)?.toDouble(),
      tdee: (json['tdee'] as num?)?.toDouble(),
      targetKcal: (json['targetKcal'] as num?)?.toDouble(),
      proteinPercent: (json['proteinPercent'] as num?)?.toDouble(),
      carbPercent: (json['carbPercent'] as num?)?.toDouble(),
      fatPercent: (json['fatPercent'] as num?)?.toDouble(),
      result: json['result'] as Map<String, dynamic>?,
    );
  }
}

