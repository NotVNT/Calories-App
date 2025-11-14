import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/auth/presentation/pages/auth_page.dart';
import 'package:calories_app/shared/state/auth_providers.dart';
import 'profile_gate.dart';

/// AuthGate - Returns LoginScreen if not signed in, otherwise ProfileGate
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        if (user == null) {
          // Not signed in -> return AuthPage directly
          return const AuthPage();
        }
        // User is signed in -> check profile/onboarding status
        return ProfileGate(uid: user.uid);
      },
      loading: () => const _LoadingScreen(),
      error: (error, stack) {
        // On error, show auth page
        return const AuthPage();
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
              'Ăn Khỏe',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

