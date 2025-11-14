import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/app/routing/profile_gate.dart';
import 'package:calories_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:calories_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:calories_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:calories_app/shared/state/auth_providers.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes and rebuild when user signs in
    // The AuthGate will handle routing automatically
  }

  void _navigateToSignUp() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToSignIn() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state - if user signs in, show ProfileGate
    final authStateAsync = ref.watch(authStateProvider);
    
    return authStateAsync.when(
      data: (user) {
        if (user != null) {
          // User signed in -> return ProfileGate which will handle routing
          return ProfileGate(uid: user.uid);
        }
        // User not signed in -> show login/signup pages
        return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SignInScreen(
          onSignUpPressed: _navigateToSignUp,
          onForgotPasswordPressed: _navigateToForgotPassword,
        ),
        SignUpScreen(
          onSignInPressed: _navigateToSignIn,
        ),
      ],
    );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SignInScreen(
            onSignUpPressed: _navigateToSignUp,
            onForgotPasswordPressed: _navigateToForgotPassword,
          ),
          SignUpScreen(
            onSignInPressed: _navigateToSignIn,
          ),
        ],
      ),
    );
  }
}

