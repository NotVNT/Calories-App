import 'package:cloud_firestore/cloud_firestore.dart';
import 'onboarding_model.dart';
import 'nutrition_result.dart';

/// Profile model for Firestore
class ProfileModel {
  final String? nickname;
  final int? age;
  final String? dobIso;
  final String? gender;
  final double? height;
  final int? heightCm;
  final double? weight;
  final double? weightKg;
  final double? bmi;
  final String? goalType;
  final double? targetWeight;
  final double? weeklyDeltaKg;
  final String? activityLevel;
  final double? activityMultiplier;
  final double? bmr;
  final double? tdee;
  final double? targetKcal;
  final double? proteinPercent;
  final double? carbPercent;
  final double? fatPercent;
  final double? proteinGrams;
  final double? carbGrams;
  final double? fatGrams;
  final DateTime? goalDate;
  final bool isCurrent;
  final DateTime? createdAt;

  const ProfileModel({
    this.nickname,
    this.age,
    this.dobIso,
    this.gender,
    this.height,
    this.heightCm,
    this.weight,
    this.weightKg,
    this.bmi,
    this.goalType,
    this.targetWeight,
    this.weeklyDeltaKg,
    this.activityLevel,
    this.activityMultiplier,
    this.bmr,
    this.tdee,
    this.targetKcal,
    this.proteinPercent,
    this.carbPercent,
    this.fatPercent,
    this.proteinGrams,
    this.carbGrams,
    this.fatGrams,
    this.goalDate,
    this.isCurrent = true,
    this.createdAt,
  });

  /// Build ProfileModel from OnboardingModel and NutritionResult
  /// Uses computed weight values (from half-kg if available) for Firestore storage
  factory ProfileModel.fromOnboarding({
    required OnboardingModel onboarding,
    required NutritionResult result,
  }) {
    return ProfileModel(
      nickname: onboarding.nickname,
      age: onboarding.age,
      dobIso: onboarding.dobIso,
      gender: onboarding.gender,
      height: onboarding.height,
      heightCm: onboarding.heightCm,
      weight: onboarding.weightKgComputed, // Use computed value
      weightKg: onboarding.weightKgComputed, // Use computed value (double for Firestore)
      bmi: onboarding.bmi,
      goalType: onboarding.goalType,
      targetWeight: onboarding.targetWeightComputed, // Use computed value
      weeklyDeltaKg: onboarding.weeklyDeltaKg,
      activityLevel: onboarding.activityLevel,
      activityMultiplier: onboarding.activityMultiplier,
      bmr: result.bmr,
      tdee: result.tdee,
      targetKcal: result.targetKcal,
      proteinPercent: result.proteinPercent,
      carbPercent: result.carbPercent,
      fatPercent: result.fatPercent,
      proteinGrams: result.proteinGrams,
      carbGrams: result.carbGrams,
      fatGrams: result.fatGrams,
      goalDate: result.goalDate,
      isCurrent: true,
      createdAt: DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'isCurrent': isCurrent,
    };

    // Add fields only if they are not null
    // Note: Type normalization will be handled by ProfileRepository._normalizeProfileData
    if (nickname != null) map['nickname'] = nickname;
    if (age != null) map['age'] = age;
    if (dobIso != null) map['dobIso'] = dobIso;
    if (gender != null) map['gender'] = gender;
    if (height != null) map['height'] = height;
    if (heightCm != null) map['heightCm'] = heightCm; // Keep as int, will be normalized if needed
    if (weight != null) map['weight'] = weight;
    if (weightKg != null) map['weightKg'] = weightKg;
    if (bmi != null) map['bmi'] = bmi;
    if (goalType != null) map['goalType'] = goalType;
    if (targetWeight != null) map['targetWeight'] = targetWeight;
    if (weeklyDeltaKg != null) map['weeklyDeltaKg'] = weeklyDeltaKg;
    if (activityLevel != null) map['activityLevel'] = activityLevel;
    if (activityMultiplier != null) map['activityMultiplier'] = activityMultiplier;
    if (bmr != null) map['bmr'] = bmr;
    if (tdee != null) map['tdee'] = tdee;
    if (targetKcal != null) map['targetKcal'] = targetKcal;
    if (proteinPercent != null) map['proteinPercent'] = proteinPercent;
    if (carbPercent != null) map['carbPercent'] = carbPercent;
    if (fatPercent != null) map['fatPercent'] = fatPercent;
    if (proteinGrams != null) map['proteinGrams'] = proteinGrams;
    if (carbGrams != null) map['carbGrams'] = carbGrams;
    if (fatGrams != null) map['fatGrams'] = fatGrams;
    if (goalDate != null) map['goalDate'] = goalDate!.toIso8601String();

    // Use serverTimestamp for createdAt
    map['createdAt'] = FieldValue.serverTimestamp();

    return map;
  }
}

