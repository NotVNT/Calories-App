import 'package:flutter/foundation.dart';

/// Profile model representing user profile stored in Firestore.
@immutable
class Profile {
  final String name;
  final String? email;
  final double? weightKg;
  final double? heightCm;
  final String? gender;
  final DateTime? birthDate;
  final int? calorieTarget;
  final String goal;
  final String? avatarUrl;
  final Map<String, double>? measurements;
  final DateTime? updatedAt;

  const Profile({
    required this.name,
    this.email,
    this.weightKg,
    this.heightCm,
    this.gender,
    this.birthDate,
    this.calorieTarget,
    this.goal = 'Duy trì',
    this.avatarUrl,
    this.measurements,
    this.updatedAt,
  });

  Profile copyWith({
    String? name,
    String? email,
    double? weightKg,
    double? heightCm,
    int? calorieTarget,
    String? goal,
    String? avatarUrl,
    DateTime? updatedAt,
    String? gender,
    DateTime? birthDate,
    Map<String, double>? measurements,
  }) {
    return Profile(
      name: name ?? this.name,
      email: email ?? this.email,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      goal: goal ?? this.goal,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      measurements: measurements ?? this.measurements,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'gender': gender,
      'birthDate': birthDate?.toUtc().toIso8601String(),
      'calorieTarget': calorieTarget,
      'goal': goal,
      'avatarUrl': avatarUrl,
      'measurements': measurements?.map((k, v) => MapEntry(k, v)),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  factory Profile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Profile(name: 'Người dùng');
    return Profile(
      name: map['name'] as String? ?? 'Người dùng',
      email: map['email'] as String?,
      weightKg: (map['weightKg'] is num)
          ? (map['weightKg'] as num).toDouble()
          : null,
      heightCm: (map['heightCm'] is num)
          ? (map['heightCm'] as num).toDouble()
          : null,
      gender: map['gender'] as String?,
      birthDate: map['birthDate'] != null
          ? DateTime.tryParse(map['birthDate'] as String)
          : null,
      calorieTarget: (map['calorieTarget'] is num)
          ? (map['calorieTarget'] as num).toInt()
          : null,
      goal: map['goal'] as String? ?? 'Duy trì',
      avatarUrl: map['avatarUrl'] as String?,
      measurements: map['measurements'] is Map
          ? Map<String, double>.from(
              (Map<String, dynamic>.from(map['measurements'] as Map)).map(
                (k, v) => MapEntry(
                  k,
                  (v is num)
                      ? v.toDouble()
                      : (double.tryParse(v.toString()) ?? 0.0),
                ),
              ),
            )
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Profile(name: $name, email: $email, weightKg: $weightKg, heightCm: $heightCm, goal: $goal, avatarUrl: $avatarUrl)';
  }
}
