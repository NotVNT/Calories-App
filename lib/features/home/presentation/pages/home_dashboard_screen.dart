import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/shared/state/auth_providers.dart';

/// Home dashboard screen - main screen after onboarding
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  /// Central sign-out handler that resets state and clears navigation stack
  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    try {
      final googleSignIn = GoogleSignIn();
      
      // Step 1: Disconnect from Google account (removes app's access)
      try {
        await googleSignIn.disconnect();
      } catch (e) {
        // Ignore disconnect errors (e.g., if already disconnected or not signed in with Google)
      }
      
      // Step 2: Sign out from Google Sign-In
      try {
        await googleSignIn.signOut();
      } catch (e) {
        // Ignore signOut errors (e.g., if not signed in with Google)
      }
      
      // Step 3: Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Step 4: Invalidate Riverpod providers to clear state
      ref.invalidate(currentProfileProvider);
      ref.invalidate(onboardingControllerProvider);
      
      // Step 5: Clear navigation stack and navigate to intro (which shows intro slides when logged out)
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/intro',
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng xuất thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        title: const Text('Ăn Khỏe'),
        backgroundColor: AppColors.mintGreen,
        foregroundColor: AppColors.nearBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleSignOut(context, ref),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 64,
              color: AppColors.mintGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'Chào mừng đến với Ăn Khỏe!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.nearBlack,
                  ),
            ),
            const SizedBox(height: 8),
            if (user != null) ...[
              Text(
                'Email: ${user.email ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mediumGray,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Hồ sơ của bạn đã được tạo thành công.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mediumGray,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

