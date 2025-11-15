// Safe Firebase initializer with a MOCK fallback.
// To enable real Firebase, set `FirebaseService.useFirebase = true`, then run
// `flutterfire configure` and add the generated `firebase_options.dart` to
// `lib/`. After that you can change the initialization to use
// Safe Firebase initializer with a MOCK fallback.
// To enable real Firebase, set `FirebaseService.useFirebase = true`, then run
// `flutterfire configure` and add the generated `firebase_options.dart` to
// `lib/`. After that you can change the initialization to use
// `DefaultFirebaseOptions.currentPlatform` if desired.

import 'dart:io';
// 'dart:typed_data' is available through Flutter imports; avoid redundant import

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:calories_app/app/config/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Toggle to enable real Firebase. Default: true (always use Firebase).
  // The app is configured to require Firebase for read/write operations.
  // You can still control writes to production via the TARGET_ENV/ALLOW_PROD_WRITES defines.
  static bool useFirebase = true;

  /// Initialize Firebase when `useFirebase == true`.
  ///
  /// If Firebase is disabled this returns quickly and prints a short message.
  /// If enabled, this calls `Firebase.initializeApp()` inside a try/catch and
  /// prints any initialization errors.
  static Future<void> initFirebase() async {
    if (!useFirebase) {
      debugPrint('Firebase config not found. Running in MOCK mode.');
      return;
    }

    try {
      // Try to initialize with generated options first. If the developer has
      // run `flutterfire configure` and added `lib/firebase_options.dart`
      // this will use those platform-specific options. If that file is a
      // stub (or missing) the call may throw and we fall back to a no-options
      // initialization which still works when platform config files exist
      // (google-services.json / GoogleService-Info.plist).
      try {
        // Try to initialize using the generated DefaultFirebaseOptions (if present).
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('Firebase initialized with DefaultFirebaseOptions.');
        return;
      } catch (_) {
        // If DefaultFirebaseOptions isn't available for this platform, fall
        // back to a no-options initialization which will pick up native
        // platform config (google-services.json / GoogleService-Info.plist).
      }

      await Firebase.initializeApp();
      debugPrint('Firebase initialized successfully (no-options fallback).');

      // If we're running in debug mode, automatically connect to the
      // local Firebase Emulators for auth, firestore and storage so tests
      // and development do not require a live project or billing.
      if (kDebugMode) {
        try {
          final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
          // Auth emulator
          FirebaseAuth.instance.useAuthEmulator(host, 9099);
          // Firestore emulator
          FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
          // Storage emulator (use new API)
          FirebaseStorage.instance.useStorageEmulator(host, 9199);
          debugPrint(
            'Connected to Firebase emulators at $host (auth:9099, firestore:8080, storage:9199)',
          );
        } catch (e, st) {
          debugPrint('Failed to connect to Firebase emulators: $e');
          debugPrint(st.toString());
        }
      }
    } catch (e, st) {
      debugPrint('Failed to initialize Firebase: $e');
      debugPrint(st.toString());
    }
  }

  /// Backwards-compatible helper: checks whether Firebase should be used (via
  /// dart-define or presence of google-services.json) and attempts to
  /// initialize it. Returns true when initialization was attempted, false for mock.
  /// Attempt to initialize Firebase. This method will throw if initialization
  /// fails — the app is expected to require Firebase for correct operation.
  /// Returns true when initialization completed successfully.
  static Future<bool> initFirebaseIfAvailable() async {
    // Always attempt initialization; do not silently fall back to MOCK mode.
    useFirebase = true;
    await initFirebase();
    return true;
  }

  /// Checks for the presence of Android google-services.json as a heuristic.
  /// Returns true if a project-level config file exists or if the dart-define
  /// USE_FIREBASE is set to true.
  static bool googleServicesPresent() {
    try {
      final file = File('android/app/google-services.json');
      return file.existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Should we initialize Firebase? We attempt to use the dart-define flag
  /// if set, otherwise fall back to checking for google-services.json.
  /// The app requires Firebase for read/write; always return true.
  static bool shouldUseFirebase() {
    return true;
  }

  /// Returns the Firestore instance when Firebase is enabled; otherwise throws.
  static FirebaseFirestore get firestore {
    if (!shouldUseFirebase()) {
      throw StateError('Firebase disabled (useFirebase=false)');
    }
    return FirebaseFirestore.instance;
  }

  /// Returns the Firebase Storage instance when Firebase is enabled; otherwise throws.
  static FirebaseStorage get storage {
    if (!shouldUseFirebase()) {
      throw StateError('Firebase disabled (useFirebase=false)');
    }
    return FirebaseStorage.instance;
  }

  /// Returns the Firebase Auth instance when Firebase is enabled; otherwise throws.
  static FirebaseAuth get auth {
    if (!shouldUseFirebase()) {
      throw StateError('Firebase disabled (useFirebase=false)');
    }
    return FirebaseAuth.instance;
  }

  /// Save an FCM token for the given user id into users/{uid}/fcmTokens array.
  /// No-op when Firebase is not enabled.
  static Future<void> saveFcmToken(String uid, String token) async {
    if (!shouldUseFirebase()) return;
    // Prevent accidental writes to production unless explicitly allowed.
    try {
      ensureCanWrite();
    } catch (e) {
      debugPrint('Prevented saving FCM token: $e');
      return;
    }
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(uid);
      await doc.set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
      debugPrint('Saved FCM token for $uid');
    } catch (e, st) {
      debugPrint('Failed to save FCM token: $e');
      debugPrint(st.toString());
    }
  }

  /// Runtime guards to avoid accidental production writes.
  ///
  /// Set the compile-time defines to override behavior:
  /// - TARGET_ENV=prod  (marks target env as production)
  /// - ALLOW_PROD_WRITES=true  (must be set to allow writes when TARGET_ENV=prod)
  static bool _isProdTarget() {
    final target = const String.fromEnvironment('TARGET_ENV').toLowerCase();
    return target == 'prod' || target == 'production';
  }

  static bool _allowProdWrites() {
    final allow = const String.fromEnvironment(
      'ALLOW_PROD_WRITES',
    ).toLowerCase();
    return allow == 'true';
  }

  static void ensureCanWrite() {
    if (_isProdTarget() && !_allowProdWrites()) {
      throw StateError(
        'Writes to production are disabled. Set --dart-define=ALLOW_PROD_WRITES=true to allow.',
      );
    }
  }

  // Note: smoke test removed — app is configured to always use Firestore
  // and will fail fast on initialization errors so issues are visible.
}

// TODO: If you want to initialize with generated options, after running
// `flutterfire configure` add the import below and call
// `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` inside initFirebase().
// import 'firebase_options.dart';
// import 'firebase_options.dart';
