import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/data/firebase/profile_repository.dart';
import 'package:calories_app/shared/state/models/user_status.dart';

/// Stream provider for Firebase Auth state changes
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

/// User profile model for currentProfileProvider
class UserProfile {
  final bool onboardingCompleted;

  const UserProfile({required this.onboardingCompleted});
}

/// Stream provider for current user's onboarding completion status
/// Watches users/{uid}.onboardingCompleted from Firestore in real-time
/// Guards against Firestore reads when user is signed out
final currentProfileProvider = StreamProvider.family<UserProfile?, String>(
  (ref, uid) {
    debugPrint('[CurrentProfileProvider] 🔵 Watching onboardingCompleted for uid=$uid');

    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(uid);

    return userDocRef.snapshots().asyncMap((snapshot) async {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null || currentUser.uid != uid) {
          debugPrint('[CurrentProfileProvider] ⚠️ User signed out or uid mismatch, returning null');
          return null;
        }

        if (snapshot.exists) {
          final data = snapshot.data();
          final onboardingCompleted = data?['onboardingCompleted'] == true;
          debugPrint('[CurrentProfileProvider] 📊 onboardingCompleted=$onboardingCompleted for uid=$uid');

          if (onboardingCompleted) {
            return const UserProfile(onboardingCompleted: true);
          }
          // If document exists but flag is false, fall through to check profiles subcollection.
        } else {
          debugPrint('[CurrentProfileProvider] ℹ️ User document does not exist for uid=$uid, checking profiles subcollection');
        }

        // When doc is missing or flag is false, check profiles subcollection.
        final profilesSnapshot = await userDocRef
            .collection('profiles')
            .limit(1)
            .get();

        final hasProfile = profilesSnapshot.docs.isNotEmpty;

        if (hasProfile) {
          debugPrint('[CurrentProfileProvider] ✅ Profile found in subcollection for uid=$uid, backfilling onboardingCompleted');
          await userDocRef.set(
            {'onboardingCompleted': true},
            SetOptions(merge: true),
          );
          return const UserProfile(onboardingCompleted: true);
        }

        debugPrint('[CurrentProfileProvider] ℹ️ No profile data found for uid=$uid, onboarding incomplete');
        return const UserProfile(onboardingCompleted: false);
      } catch (error, stackTrace) {
        debugPrint('[CurrentProfileProvider] 🔥 Error while resolving onboarding status for uid=$uid: $error');
        debugPrintStack(stackTrace: stackTrace);
        // On error, emit null so the UI can decide how to handle (usually treated as onboarding needed).
        return null;
      }
    });
  },
);

/// Future provider for user status (profile and onboarding state)
/// Automatically backfills onboardingCompleted flag if profile exists but flag is missing
/// Guards against Firestore reads when user is signed out
final userStatusProvider = FutureProvider.family<UserStatus, String>(
  (ref, uid) async {
    debugPrint('[UserStatusProvider] 🔵 Checking user status for uid=$uid');
    
    // Guard: Check if user is still signed in before Firestore queries
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != uid) {
      debugPrint('[UserStatusProvider] ⚠️ User signed out or uid mismatch, returning default status');
      return UserStatus(
        hasProfile: false,
        onboardingCompleted: false,
      );
    }
    
    try {
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(uid);

      // Check user document for onboardingCompleted flag
      final userDoc = await userDocRef.get();
      
      // Double-check user is still signed in after async operation
      final currentUserAfter = FirebaseAuth.instance.currentUser;
      if (currentUserAfter == null || currentUserAfter.uid != uid) {
        debugPrint('[UserStatusProvider] ⚠️ User signed out during query, returning default status');
        return UserStatus(
          hasProfile: false,
          onboardingCompleted: false,
        );
      }
      
      final hasFlag = userDoc.exists && userDoc.data()?['onboardingCompleted'] == true;

      if (hasFlag) {
        debugPrint('[UserStatusProvider] ✅ Flag exists for uid=$uid');
        return UserStatus(
          hasProfile: true,
          onboardingCompleted: true,
        );
      }

      // Check for profiles subcollection
      final profilesSnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .limit(1)
          .get();

      // Double-check user is still signed in after second async operation
      final currentUserAfter2 = FirebaseAuth.instance.currentUser;
      if (currentUserAfter2 == null || currentUserAfter2.uid != uid) {
        debugPrint('[UserStatusProvider] ⚠️ User signed out during query, returning default status');
        return UserStatus(
          hasProfile: false,
          onboardingCompleted: false,
        );
      }

      final hasProfile = profilesSnapshot.docs.isNotEmpty;

      if (hasProfile) {
        debugPrint('[UserStatusProvider] 📋 Profile exists but flag missing, backfilling for uid=$uid');
        // Backfill onboardingCompleted flag using repository
        final repository = ProfileRepository();
        await repository.backfillOnboardingFlag(uid);
        
        return UserStatus(
          hasProfile: true,
          onboardingCompleted: true,
        );
      }

      debugPrint('[UserStatusProvider] ℹ️ No profile found for uid=$uid');
      return UserStatus(
        hasProfile: false,
        onboardingCompleted: false,
      );
    } catch (e) {
      // Handle PERMISSION_DENIED and other Firestore errors gracefully
      if (e.toString().contains('PERMISSION_DENIED') || 
          e.toString().contains('permission-denied')) {
        debugPrint('[UserStatusProvider] ⚠️ Permission denied for uid=$uid (user may have signed out): $e');
        return UserStatus(
          hasProfile: false,
          onboardingCompleted: false,
        );
      }
      debugPrint('[UserStatusProvider] ⚠️ Error checking user status: $e');
      rethrow;
    }
  },
);

