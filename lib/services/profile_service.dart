import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Storage is accessed via FirebaseService.storage; explicit import not required here.
import '../models/profile.dart';
import 'firebase_service.dart';

/// ProfileService provides methods to read/write profiles and upload avatars.
/// It supports two modes: Firebase-backed and in-memory mock. The service
/// decides mode using FirebaseService.shouldUseFirebase().
class ProfileService {
  ProfileService._();

  static Future<ProfileService> create() async {
    // Require Firebase for profile operations. If Firebase is not enabled
    // this indicates a misconfiguration and we fail early so problems are visible.
    if (!FirebaseService.shouldUseFirebase()) {
      throw StateError(
        'Firebase is required for ProfileService but is not configured.',
      );
    }
    return ProfileService._();
  }

  /// Fetch profile for the given uid. If firebase is enabled, reads from
  /// Firestore at users/{uid}/profile. If not, returns from in-memory store or default.
  Future<Profile> fetchProfile(String uid) async {
    try {
      final firestore = FirebaseService.firestore;
      final docRef = firestore.collection('users').doc(uid);
      final doc = await docRef.get();
      final topLevel = doc.data();

      // Prefer profiles subcollection as canonical source for onboarding/profile data.
      try {
        final profilesSnapshot = await docRef
            .collection('profiles')
            .where('isCurrent', isEqualTo: true)
            .limit(1)
            .get();

        if (profilesSnapshot.docs.isNotEmpty) {
          final profileDoc = profilesSnapshot.docs.first.data();
          debugPrint(
            '[ProfileService] ℹ️ Using profile from subcollection for uid=$uid',
          );
          return Profile.fromMap(profileDoc);
        }
      } catch (e) {
        debugPrint(
          '[ProfileService] ⚠️ Failed to read profiles subcollection for uid=$uid: $e',
        );
      }

      // Fallback to top-level doc if no profile in subcollection
      if (topLevel != null && topLevel.isNotEmpty) {
        return Profile.fromMap(topLevel);
      }

      return const Profile(name: 'Người dùng');
    } catch (e) {
      debugPrint('Firestore read failed: $e');
      rethrow;
    }
  }

  /// Update profile in Firestore or local store, and return updated profile.
  Future<Profile> updateProfile(String uid, Profile profile) async {
    final updated = profile.copyWith(updatedAt: DateTime.now().toUtc());
    try {
      FirebaseService.ensureCanWrite();
      final firestore = FirebaseService.firestore;
      // Write profile data into the canonical `profiles` subcollection as the
      // current profile document. We create or update a document marked
      // `isCurrent: true` so reads can prefer it.
      final userRef = firestore.collection('users').doc(uid);
      // Try to find existing current profile
      final existing = await userRef
          .collection('profiles')
          .where('isCurrent', isEqualTo: true)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        final docRef = existing.docs.first.reference;
        await docRef.set(updated.toMap(), SetOptions(merge: true));
      } else {
        final newRef = userRef.collection('profiles').doc();
        final m = updated.toMap();
        m['isCurrent'] = true;
        await newRef.set(m);
      }
      return updated;
    } catch (e) {
      debugPrint('Firestore write failed: $e');
      rethrow;
    }
  }

  /// Update arbitrary fields on the current profile document under
  /// `users/{uid}/profiles`. If there's no current profile yet, create one.
  Future<void> updateCurrentProfileFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    try {
      FirebaseService.ensureCanWrite();
      final firestore = FirebaseService.firestore;
      final userRef = firestore.collection('users').doc(uid);

      final snap = await userRef
          .collection('profiles')
          .where('isCurrent', isEqualTo: true)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final docRef = snap.docs.first.reference;
        final update = Map.of(fields)
          ..['updatedAt'] = FieldValue.serverTimestamp();
        await docRef.set(update, SetOptions(merge: true));
        return;
      }

      final newRef = userRef.collection('profiles').doc();
      final data = Map.of(fields)
        ..['isCurrent'] = true
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await newRef.set(data);
    } catch (e) {
      debugPrint('Failed to update current profile fields: $e');
      rethrow;
    }
  }

  /// Delete all stored data for a given user. When running with Firebase enabled
  /// this will attempt to remove the profile document and avatar files. In
  /// MOCK mode this removes the profile from the in-memory store.
  Future<void> deleteAccount(String uid) async {
    try {
      FirebaseService.ensureCanWrite();
      final firestore = FirebaseService.firestore;
      await firestore.collection('users').doc(uid).delete();
    } catch (e) {
      debugPrint('Failed to delete profile doc: $e');
      rethrow;
    }

    try {
      final storage = FirebaseService.storage;
      final ref = storage.ref('avatars/$uid');
      await ref.delete();
    } catch (e) {
      debugPrint('Failed to delete avatar storage: $e');
      // Non-fatal — just log and continue
    }
  }

  /// Change the password of the currently signed-in user.
  /// Returns true if the password update completed (or was a no-op in mock),
  /// throws on errors from FirebaseAuth when running with Firebase enabled.
  Future<bool> changePassword(String newPassword) async {
    try {
      final user = FirebaseService.auth.currentUser;
      if (user == null) throw StateError('No authenticated user');
      await user.updatePassword(newPassword);
      debugPrint('Password updated for uid=${user.uid}');
      return true;
    } catch (e) {
      debugPrint('Failed to update password: $e');
      rethrow;
    }
  }

  /// Uploads avatar file and returns a URL (download URL) or local path.
  /// When useFirebase is true, it uploads to Firebase Storage at avatars/{uid}/{ts}.jpg
  Future<String?> uploadAvatar(String uid, XFile file) async {
    try {
      FirebaseService.ensureCanWrite();

      final useStorage = const String.fromEnvironment(
        'USE_STORAGE',
        defaultValue: 'true',
      );
      if (useStorage.toLowerCase() == 'false') {
        final bytes = await file.readAsBytes();
        final b64 = base64Encode(bytes);
        final firestore = FirebaseService.firestore;
        await firestore.collection('users').doc(uid).set({
          'avatarBase64': b64,
        }, SetOptions(merge: true));
        return 'data:image;base64:${b64.substring(0, 40)}...';
      }

      final storage = FirebaseService.storage;
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = storage.ref('avatars/$uid/$ts.jpg');
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Storage upload failed: $e');
      rethrow;
    }
  }

  /// Save a measurement for the given user.
  /// This will append a history document in `users/{uid}/measurements_history`
  /// and update a `measurements.latest.{type}` field on the user document.
  /// Uses a batched write so both changes are committed together when using
  /// Firestore.
  Future<void> saveMeasurement(
    String uid, {
    required String type,
    required double value,
    String unit = 'kg',
    String? note,
    String? imageUrl,
  }) async {
    final now = DateTime.now().toUtc();

    try {
      FirebaseService.ensureCanWrite();
      final firestore = FirebaseService.firestore;
      final userRef = firestore.collection('users').doc(uid);
      final historyCol = userRef.collection('measurements_history');

      final batch = firestore.batch();
      final historyDoc = historyCol.doc();
      final historyData = {
        'type': type,
        'value': value,
        'unit': unit,
        'note': note,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'ts': FieldValue.serverTimestamp(),
      }..removeWhere((k, v) => v == null);

      batch.set(historyDoc, historyData);
      final latestPath = 'measurements.latest.$type';
      final updateData = <String, dynamic>{
        latestPath: value,
        'updatedAt': now.toUtc().toIso8601String(),
      };
      batch.set(userRef, updateData, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      debugPrint('Failed to save measurement: $e');
      rethrow;
    }
  }

  // Helper to lazily import firestore (dynamic to avoid static dependency in some dev flows)
  // Using FirebaseService.firestore and FirebaseService.storage directly.
}
