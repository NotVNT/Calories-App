/// User status model for tracking profile and onboarding state
class UserStatus {
  final bool hasProfile;
  final bool onboardingCompleted;

  UserStatus({
    required this.hasProfile,
    required this.onboardingCompleted,
  });

  /// User is ready to use the app (has completed onboarding)
  bool get isReady => onboardingCompleted;

  /// User needs to complete onboarding
  bool get needsOnboarding => hasProfile == false || onboardingCompleted == false;
}

