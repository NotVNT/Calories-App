import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Profile repository for Firestore operations
class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRepository({
    FirebaseFirestore? instance,
    FirebaseAuth? auth,
  })  : _firestore = instance ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user has an existing profile
  Future<bool> hasExistingProfile() async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final profilesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .limit(1);

      final snapshot = await profilesRef.get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // If error, assume no profile exists
      return false;
    }
  }

  /// Get user profiles
  Future<List<Map<String, dynamic>>> getUserProfiles() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .get();

      return snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save onboarding profile and set onboardingCompleted flag
  /// This is the single source of truth for profile writes
  /// 
  /// [uid] - User ID from FirebaseAuth.instance.currentUser!.uid
  /// [profile] - Profile data map (will be normalized)
  /// 
  /// Throws exception on failure with detailed logging
  Future<String> saveProfile(String uid, Map<String, dynamic> profile) async {
    debugPrint('[ProfileRepository] 🔵 Starting saveProfile for uid=$uid');
    
    try {
      // Step 1: Normalize numeric types (int -> double for consistency)
      final normalized = _normalizeProfileData(profile);
      
      debugPrint('[ProfileRepository] 📊 Normalized profile data: ${normalized.keys.toList()}');
      
      // Step 2: Ensure required fields
      normalized['isCurrent'] = normalized['isCurrent'] ?? true;
      normalized['createdAt'] = FieldValue.serverTimestamp();
      
      // Step 3: Get user document reference
      final userDocRef = _firestore.collection('users').doc(uid);
      
      // Step 4: Create batch for atomic operations
      final batch = _firestore.batch();
      
      // Step 5: Set all other profiles to isCurrent=false
      final currentProfilesQuery = userDocRef
          .collection('profiles')
          .where('isCurrent', isEqualTo: true);
      
      final currentProfilesSnapshot = await currentProfilesQuery.get();
      debugPrint('[ProfileRepository] 📋 Found ${currentProfilesSnapshot.docs.length} existing current profiles');
      
      for (var doc in currentProfilesSnapshot.docs) {
        batch.update(doc.reference, {'isCurrent': false});
      }
      
      // Step 6: Add new profile document
      final newProfileRef = userDocRef.collection('profiles').doc();
      batch.set(newProfileRef, normalized);
      
      debugPrint('[ProfileRepository] 📝 Created new profile doc: ${newProfileRef.id}');
      
      // Step 7: Set onboardingCompleted flag on user document
      batch.set(
        userDocRef,
        {'onboardingCompleted': true},
        SetOptions(merge: true),
      );
      
      debugPrint('[ProfileRepository] ✅ Setting onboardingCompleted=true for uid=$uid');
      
      // Step 8: Commit batch (all operations are atomic)
      await batch.commit();
      
      debugPrint('[ProfileRepository] 🎉 Successfully saved profile ${newProfileRef.id} and set onboardingCompleted for uid=$uid');
      
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

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .where('isCurrent', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return {
        'id': doc.id,
        ...doc.data(),
      };
    });
  }

  /// Mark onboarding as completed for the current user
  /// Sets onboardingCompleted = true in users/{uid}
  /// NOTE: This is now handled in saveProfile() - kept for backward compatibility
  @Deprecated('Use saveProfile() which handles both profile save and flag setting')
  Future<void> markOnboardingCompleted() async {
    final userId = currentUserId;
    if (userId == null) {
      debugPrint('[ProfileRepository] ⚠️ markOnboardingCompleted: No current user');
      return;
    }

    try {
      debugPrint('[ProfileRepository] 🔵 Marking onboardingCompleted=true for uid=$userId');
      await _firestore
          .collection('users')
          .doc(userId)
          .set(
        {'onboardingCompleted': true},
        SetOptions(merge: true),
      );
      debugPrint('[ProfileRepository] ✅ Successfully set onboardingCompleted for uid=$userId');
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] 🔥 markOnboardingCompleted FAILED for uid=$userId');
      debugPrint('[ProfileRepository] Error: $e');
      debugPrint('[ProfileRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Backfill onboardingCompleted flag if profile exists but flag is missing
  Future<void> backfillOnboardingFlag(String uid) async {
    try {
      debugPrint('[ProfileRepository] 🔵 Checking backfill for uid=$uid');
      final userDocRef = _firestore.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      // If flag already exists and is true, no need to backfill
      if (userDoc.exists && userDoc.data()?['onboardingCompleted'] == true) {
        debugPrint('[ProfileRepository] ✅ Flag already exists for uid=$uid, skipping backfill');
        return;
      }

      // Check if profiles exist
      final profilesSnapshot = await userDocRef
          .collection('profiles')
          .limit(1)
          .get();

      if (profilesSnapshot.docs.isNotEmpty) {
        debugPrint('[ProfileRepository] 📋 Found ${profilesSnapshot.docs.length} profile(s), backfilling flag for uid=$uid');
        // Backfill the flag
        await userDocRef.set(
          {'onboardingCompleted': true},
          SetOptions(merge: true),
        );
        debugPrint('[ProfileRepository] ✅ Successfully backfilled onboardingCompleted for uid=$uid');
      } else {
        debugPrint('[ProfileRepository] ℹ️ No profiles found for uid=$uid, no backfill needed');
      }
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] 🔥 backfillOnboardingFlag FAILED for uid=$uid');
      debugPrint('[ProfileRepository] Error: $e');
      debugPrint('[ProfileRepository] Stack trace: $stackTrace');
      // Don't rethrow - backfill is not critical
    }
  }
}

