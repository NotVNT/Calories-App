import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Onboarding analytics logger
/// Exposes methods to log onboarding events to Firebase Analytics
class OnboardingLogger {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log when an onboarding step is viewed
  /// 
  /// [stepName] - Name of the step (e.g., 'welcome', 'nickname', 'gender', 'dob', etc.)
  /// [durationMs] - Time spent on previous step in milliseconds (0 for first step)
  static Future<void> logStepViewed({
    required String stepName,
    int durationMs = 0,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_step_viewed',
        parameters: {
          'step_name': stepName,
          'duration_ms': durationMs,
        },
      );
    } catch (e) {
      // Silently fail analytics logging to not break the app
      debugPrint('Failed to log onboarding_step_viewed: $e');
    }
  }

  /// Log when onboarding is completed
  /// 
  /// [stepName] - Name of the final step (usually 'target_intake' or 'macro')
  /// [durationMs] - Total time spent on onboarding in milliseconds
  /// [totalSteps] - Total number of steps completed
  static Future<void> logOnboardingCompleted({
    required String stepName,
    required int durationMs,
    int totalSteps = 11,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_completed',
        parameters: {
          'step_name': stepName,
          'duration_ms': durationMs,
          'total_steps': totalSteps,
        },
      );
    } catch (e) {
      // Silently fail analytics logging to not break the app
      debugPrint('Failed to log onboarding_completed: $e');
    }
  }

  /// Log when user skips onboarding (if applicable)
  static Future<void> logOnboardingSkipped({
    String? reason,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_skipped',
        parameters: {
          if (reason != null) 'reason': reason,
        },
      );
    } catch (e) {
      debugPrint('Failed to log onboarding_skipped: $e');
    }
  }

  /// Log when user abandons onboarding
  /// 
  /// [stepName] - Name of the step where user abandoned
  /// [durationMs] - Total time spent before abandoning
  static Future<void> logOnboardingAbandoned({
    required String stepName,
    required int durationMs,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_abandoned',
        parameters: {
          'step_name': stepName,
          'duration_ms': durationMs,
        },
      );
    } catch (e) {
      debugPrint('Failed to log onboarding_abandoned: $e');
    }
  }
}
