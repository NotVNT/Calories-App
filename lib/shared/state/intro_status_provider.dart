import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist whether the intro carousel has been completed on device.
const _introSeenKey = 'has_seen_intro_v1';

/// Controls the intro completion state backed by SharedPreferences.
class IntroStatusNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introSeenKey) ?? false;
  }

  /// Mark the intro carousel as completed for this device.
  Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, true);
    state = const AsyncValue.data(true);
  }

  /// Reset the stored flag (useful for debugging or account reset flows).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_introSeenKey);
    state = const AsyncValue.data(false);
  }
}

final introStatusProvider =
    AsyncNotifierProvider<IntroStatusNotifier, bool>(IntroStatusNotifier.new);

