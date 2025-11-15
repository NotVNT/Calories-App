import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ProfileRepository not needed anymore; top-level users/{uid} is canonical
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
final currentProfileProvider = StreamProvider.family<UserProfile?, String>((
  ref,
  uid,
) {
  debugPrint(
    '[CurrentProfileProvider] 🔵 Watching onboardingCompleted for uid=$uid',
  );

  final firestore = FirebaseFirestore.instance;
  final userDocRef = firestore.collection('users').doc(uid);

  return userDocRef.snapshots().map((snapshot) {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != uid) {
        debugPrint(
          '[CurrentProfileProvider] ⚠️ User signed out or uid mismatch, returning null',
        );
        return null;
      }

      if (snapshot.exists) {
        final data = snapshot.data();
        final onboardingCompleted = data?['onboardingCompleted'] == true;
        debugPrint(
          '[CurrentProfileProvider] 📊 onboardingCompleted=$onboardingCompleted for uid=$uid',
        );
        return UserProfile(onboardingCompleted: onboardingCompleted);
      }

      debugPrint(
        '[CurrentProfileProvider] ℹ️ No top-level user document for uid=$uid',
      );
      return const UserProfile(onboardingCompleted: false);
    } catch (error, stackTrace) {
      debugPrint(
        '[CurrentProfileProvider] 🔥 Error while resolving onboarding status for uid=$uid: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  });
});

/// Future provider for user status (profile and onboarding state)
/// Automatically backfills onboardingCompleted flag if profile exists but flag is missing
/// Guards against Firestore reads when user is signed out
final userStatusProvider = FutureProvider.family<UserStatus, String>((
  ref,
  uid,
) async {
  debugPrint('[UserStatusProvider] 🔵 Checking user status for uid=$uid');

  // Guard: Check if user is still signed in before Firestore queries
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null || currentUser.uid != uid) {
    debugPrint(
      '[UserStatusProvider] ⚠️ User signed out or uid mismatch, returning default status',
    );
    return UserStatus(hasProfile: false, onboardingCompleted: false);
  }

  try {
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(uid);

    // Check top-level user document for onboarding status
    final userDoc = await userDocRef.get();

    // Double-check user is still signed in after async operation
    final currentUserAfter = FirebaseAuth.instance.currentUser;
    if (currentUserAfter == null || currentUserAfter.uid != uid) {
      debugPrint(
        '[UserStatusProvider] ⚠️ User signed out during query, returning default status',
      );
      return UserStatus(hasProfile: false, onboardingCompleted: false);
    }

    if (userDoc.exists && (userDoc.data()?['onboardingCompleted'] == true)) {
      debugPrint('[UserStatusProvider] ✅ Top-level flag exists for uid=$uid');
      return UserStatus(hasProfile: true, onboardingCompleted: true);
    }

    debugPrint(
      '[UserStatusProvider] ℹ️ No top-level profile found for uid=$uid',
    );
    return UserStatus(hasProfile: false, onboardingCompleted: false);
  } catch (e) {
    // Handle PERMISSION_DENIED and other Firestore errors gracefully
    if (e.toString().contains('PERMISSION_DENIED') ||
        e.toString().contains('permission-denied')) {
      debugPrint(
        '[UserStatusProvider] ⚠️ Permission denied for uid=$uid (user may have signed out): $e',
      );
      return UserStatus(hasProfile: false, onboardingCompleted: false);
    }
    debugPrint('[UserStatusProvider] ⚠️ Error checking user status: $e');
    rethrow;
  }
});
