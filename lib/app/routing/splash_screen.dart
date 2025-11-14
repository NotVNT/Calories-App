import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/auth/presentation/pages/auth_page.dart';
import 'package:calories_app/features/home/presentation/screens/home_screen.dart';
import 'package:calories_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:calories_app/shared/state/auth_providers.dart';

/// Splash screen that handles authentication and onboarding routing
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        if (user == null) {
          // Not signed in -> go to AuthPage
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AuthPage()),
            );
          });
          return _buildLoading(context);
        }

        // User is signed in -> check onboarding status
        final userStatusAsync = ref.watch(userStatusProvider(user.uid));

        return userStatusAsync.when(
          data: (userStatus) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (userStatus.onboardingCompleted) {
                // User has completed onboarding -> go to Home
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              } else {
                // User needs onboarding -> go to WelcomeScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              }
            });
            return _buildLoading(context);
          },
          loading: () => _buildLoading(context),
          error: (error, stack) {
            // On error, assume user needs onboarding
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              );
            });
            return _buildLoading(context);
          },
        );
      },
      loading: () => _buildLoading(context),
      error: (error, stack) {
        // Auth error -> go to AuthPage
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthPage()),
          );
        });
        return _buildLoading(context);
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or loading indicator
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

