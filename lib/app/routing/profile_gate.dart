import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/home/presentation/screens/home_screen.dart';
import 'package:calories_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:calories_app/shared/state/auth_providers.dart';

/// ProfileGate - Returns HomeScreen if onboarding completed, otherwise OnboardingFlow
/// Uses currentProfileProvider (StreamProvider) for real-time updates
class ProfileGate extends ConsumerWidget {
  final String uid;

  const ProfileGate({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider(uid));

    return profileAsync.when(
      data: (profile) {
        if (profile?.onboardingCompleted == true) {
          // User has completed onboarding -> return Home directly
          return const HomeScreen();
        } else {
          // User needs onboarding -> return WelcomeScreen (onboarding flow)
          return const WelcomeScreen();
        }
      },
      loading: () => const _LoadingScreen(),
      error: (error, stack) {
        // On error, assume user needs onboarding
        debugPrint('[ProfileGate] ⚠️ Error reading profile: $error');
        return const WelcomeScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Đang tải...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

