import 'package:flutter/material.dart';
import 'package:calories_app/features/onboarding/data/services/onboarding_logger.dart';

/// Mixin to track onboarding step analytics
mixin OnboardingAnalyticsMixin<T extends StatefulWidget> on State<T> {
  DateTime? _stepStartTime;
  String? _currentStepName;

  /// Initialize step tracking
  /// Call this in initState or when step is first viewed
  void initStepTracking(String stepName) {
    _currentStepName = stepName;
    _stepStartTime = DateTime.now();
    
    // Log step viewed (duration is 0 for first view)
    OnboardingLogger.logStepViewed(
      stepName: stepName,
      durationMs: 0,
    );
  }

  /// Track step completion and log duration
  /// Call this when leaving the step
  Future<void> trackStepCompletion(String nextStepName) async {
    if (_stepStartTime != null && _currentStepName != null) {
      final duration = DateTime.now().difference(_stepStartTime!);
      final durationMs = duration.inMilliseconds;
      
      // Log step viewed for next step with duration
      await OnboardingLogger.logStepViewed(
        stepName: nextStepName,
        durationMs: durationMs,
      );
    }
  }

  /// Track onboarding completion
  /// Call this when onboarding is fully completed
  Future<void> trackOnboardingCompleted() async {
    if (_stepStartTime != null && _currentStepName != null) {
      final duration = DateTime.now().difference(_stepStartTime!);
      final durationMs = duration.inMilliseconds;
      
      await OnboardingLogger.logOnboardingCompleted(
        stepName: _currentStepName!,
        durationMs: durationMs,
        totalSteps: 11,
      );
    }
  }

  /// Track onboarding abandonment
  /// Call this when user leaves onboarding without completing
  Future<void> trackOnboardingAbandoned() async {
    if (_stepStartTime != null && _currentStepName != null) {
      final duration = DateTime.now().difference(_stepStartTime!);
      final durationMs = duration.inMilliseconds;
      
      await OnboardingLogger.logOnboardingAbandoned(
        stepName: _currentStepName!,
        durationMs: durationMs,
      );
    }
  }
}

