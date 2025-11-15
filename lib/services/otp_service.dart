import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple OTP mock service for development.
/// - `requestOtp(email)` generates a 6-digit code, stores it in SharedPreferences
///   with a timestamp and returns true.
/// - `verifyOtp(email, code)` validates code and expiry (default 10 minutes).
/// This is only for local/dev testing; replace with a real backend in production.
class OtpService {
  static const _kOtpKeyPrefix = 'mock_otp_';
  static const _kOtpTsPrefix = 'mock_otp_ts_';
  static const _expirySec = 10 * 60; // 10 minutes

  /// Generate and persist OTP for [email]. Returns the generated code (for
  /// dev/debug). In production you would not return the code to the client.
  static Future<String> requestOtp(String email) async {
    final rnd = Random.secure();
    final code = (rnd.nextInt(900000) + 100000).toString();
    final sp = await SharedPreferences.getInstance();
    await sp.setString('$_kOtpKeyPrefix$email', code);
    await sp.setInt(
      '$_kOtpTsPrefix$email',
      DateTime.now().millisecondsSinceEpoch,
    );
    // In dev, log the code so developer/tester can copy it.
    // DO NOT expose this in production.
    // ignore: avoid_print
    print('OTP for $email: $code');
    return code;
  }

  /// Verify OTP for [email]. Returns true if valid and not expired.
  static Future<bool> verifyOtp(String email, String code) async {
    final sp = await SharedPreferences.getInstance();
    final stored = sp.getString('$_kOtpKeyPrefix$email');
    final ts = sp.getInt('$_kOtpTsPrefix$email');
    if (stored == null || ts == null) return false;
    final created = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    if (now.difference(created).inSeconds > _expirySec) {
      // expired
      await sp.remove('$_kOtpKeyPrefix$email');
      await sp.remove('$_kOtpTsPrefix$email');
      return false;
    }
    final ok = stored == code;
    if (ok) {
      // consume
      await sp.remove('$_kOtpKeyPrefix$email');
      await sp.remove('$_kOtpTsPrefix$email');
    }
    return ok;
  }
}
