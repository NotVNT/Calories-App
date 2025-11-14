import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  // [forceAccountSelection]: If true, always shows account chooser even if user is already signed in
  Future<UserCredential?> signInWithGoogle({bool forceAccountSelection = false}) async {
    try {
      GoogleSignInAccount? googleUser;
      
      if (forceAccountSelection) {
        // Force account selection by signing out first, then showing chooser
        await _googleSignIn.signOut();
        googleUser = await _googleSignIn.signIn();
      } else {
        // Fast login: try to sign in silently first, then show chooser if needed
        // Note: We don't call signInSilently() here to avoid bypassing the chooser
        // Instead, we directly call signIn() which will show the chooser if needed
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  // Disconnects from Google account and signs out from both Google and Firebase
  Future<void> signOut() async {
    try {
      // First disconnect from Google (removes app's access to Google account)
      await _googleSignIn.disconnect();
    } catch (e) {
      // Ignore disconnect errors (e.g., if already disconnected)
    }
    
    // Then sign out from Google and Firebase
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

