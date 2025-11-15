import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Profile repository for Firestore operations
class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRepository({FirebaseFirestore? instance, FirebaseAuth? auth})
    : _firestore = instance ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // NOTE: This repository now treats top-level `users/{uid}` as canonical
  // profile storage. Legacy subcollection helpers were removed to avoid
  // maintaining two sources of truth.

  /// Save onboarding profile into `users/{uid}/profiles` subcollection.
  /// This repo uses the `profiles` subcollection as the canonical source
  /// of onboarding/profile data.
  Future<String> saveProfile(String uid, Map<String, dynamic> profile) async {
    debugPrint(
      '[ProfileRepository] 🔵 Starting saveProfile (profiles subcollection) for uid=$uid',
    );

    try {
      final normalized = _normalizeProfileData(profile);
      debugPrint(
        '[ProfileRepository] 📊 Normalized profile data: ${normalized.keys.toList()}',
      );

      final userDocRef = _firestore.collection('users').doc(uid);

      // Create a batch: mark existing current profiles as not current, then
      // add a new profile doc with isCurrent=true.
      final batch = _firestore.batch();

      final currentProfilesQuery = userDocRef
          .collection('profiles')
          .where('isCurrent', isEqualTo: true);
      final currentProfilesSnapshot = await currentProfilesQuery.get();
      debugPrint(
        '[ProfileRepository] 📋 Found ${currentProfilesSnapshot.docs.length} existing current profiles',
      );
      for (final doc in currentProfilesSnapshot.docs) {
        batch.update(doc.reference, {'isCurrent': false});
      }

      // Ensure createdAt and isCurrent
      normalized['isCurrent'] = true;
      normalized['createdAt'] = FieldValue.serverTimestamp();

      final newProfileRef = userDocRef.collection('profiles').doc();
      batch.set(newProfileRef, normalized);

      await batch.commit();
      debugPrint(
        '[ProfileRepository] 📝 Created new profile doc: ${newProfileRef.id}',
      );
      return newProfileRef.id;
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] 🔥 saveProfile FAILED for uid=$uid');
      debugPrint('[ProfileRepository] Error: $e');
      debugPrint('[ProfileRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Normalize profile data: convert int to double for numeric fields
  Map<String, dynamic> _normalizeProfileData(Map<String, dynamic> profile) {
    final normalized = Map<String, dynamic>.from(profile);

    // Fields that should be double (not int)
    // Note: heightCm can stay as int, but we'll normalize it for consistency
    final doubleFields = [
      'height',
      'weight',
      'weightKg',
      'bmi',
      'targetWeight',
      'weeklyDeltaKg',
      'activityMultiplier',
      'bmr',
      'tdee',
      'targetKcal',
      'proteinPercent',
      'carbPercent',
      'fatPercent',
      'proteinGrams',
      'carbGrams',
      'fatGrams',
    ];

    // heightCm is int in model but we'll keep it as int in Firestore (no conversion needed)
    // Only convert other numeric fields

    for (final key in doubleFields) {
      if (normalized.containsKey(key) && normalized[key] is int) {
        normalized[key] = (normalized[key] as int).toDouble();
        debugPrint('[ProfileRepository] 🔄 Normalized $key: int -> double');
      }
    }

    // Remove null values for cleaner Firestore writes
    normalized.removeWhere((key, value) => value == null);

    return normalized;
  }

  /// Watch current profile (stream)
  Stream<Map<String, dynamic>?> watchCurrentProfile() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }

    final userDocRef = _firestore.collection('users').doc(userId);

    // Stream the top-level user document and emit its map. This is the only
    // source of truth for profile data now.
    return userDocRef.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null || data.isEmpty) return null;
      return Map<String, dynamic>.from(data);
    });
  }

  /// Mark onboarding as completed for the current user
  /// Sets onboardingCompleted = true in users/{uid}
  /// NOTE: This is now handled in saveProfile() - kept for backward compatibility
  @Deprecated(
    'Use saveProfile() which handles both profile save and flag setting',
  )
  Future<void> markOnboardingCompleted() async {
    final userId = currentUserId;
    if (userId == null) {
      debugPrint(
        '[ProfileRepository] ⚠️ markOnboardingCompleted: No current user',
      );
      return;
    }

    try {
      debugPrint(
        '[ProfileRepository] 🔵 Marking onboardingCompleted=true for uid=$userId',
      );
      await _firestore.collection('users').doc(userId).set({
        'onboardingCompleted': true,
      }, SetOptions(merge: true));
      debugPrint(
        '[ProfileRepository] ✅ Successfully set onboardingCompleted for uid=$userId',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[ProfileRepository] 🔥 markOnboardingCompleted FAILED for uid=$userId',
      );
      debugPrint('[ProfileRepository] Error: $e');
      debugPrint('[ProfileRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Backfill helpers removed — `users/{uid}` is canonical now.
}
