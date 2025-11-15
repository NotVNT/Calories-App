import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/auth/presentation/pages/auth_page.dart';
import 'package:calories_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:calories_app/shared/state/auth_providers.dart';
import 'package:calories_app/shared/state/intro_status_provider.dart';
import 'profile_gate.dart';

/// IntroGate - Root gate that shows intro slides before login
/// Logic:
/// - If user == null → show OnboardingPage (3 intro slides) → then LoginScreen
/// - If user != null → check onboardingCompleted → HomeScreen or OnboardingFlow
class IntroGate extends ConsumerWidget {
  const IntroGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introAsync = ref.watch(introStatusProvider);
    final authAsync = ref.watch(authStateProvider);

    return introAsync.when(
      data: (hasSeenIntro) {
        return authAsync.when(
          data: (user) {
            if (user == null) {
              // User is not logged in → show AuthPage first.
              // Onboarding is available but should not block login; keep
              // onboarding optional so the user can sign in immediately.
              return const AuthPage();
            }

            // User is logged in → check onboarding status via ProfileGate
            return ProfileGate(uid: user.uid);
          },
          loading: () => const _LoadingScreen(),
          error: (error, stack) {
            debugPrint('[IntroGate] authStateProvider error: $error');
            // On auth errors, fallback to AuthPage so user can try to sign in.
            return const AuthPage();
          },
        );
      },
      loading: () => const _LoadingScreen(),
      error: (error, stackTrace) {
        debugPrint('[IntroGate] introStatusProvider error: $error');
        // If intro flag fails to load, default to showing intro.
        return const OnboardingPage();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
