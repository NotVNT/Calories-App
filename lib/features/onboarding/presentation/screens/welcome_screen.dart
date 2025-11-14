import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';
import 'package:calories_app/features/onboarding/data/services/onboarding_logger.dart';
import 'package:calories_app/features/onboarding/data/services/onboarding_persistence_service.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/mascot_widget.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/speech_bubble_widget.dart';
import 'package:calories_app/shared/state/auth_providers.dart';
import 'nickname_step_screen.dart';

/// Welcome screen - first step of onboarding
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Guard: Check if user is authenticated, redirect to login if not
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        // User is not authenticated - redirect to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        return;
      }
    });
    
    // Track welcome screen view
    OnboardingLogger.logStepViewed(stepName: 'welcome', durationMs: 0);
  }

  /// Initialize onboarding state and navigate to nickname step
  void _onStartPressed() {
    // Reset onboarding state and clear draft
    ref.read(onboardingControllerProvider.notifier).reset();
    OnboardingPersistenceService.clearDraft();
    
    // Track step completion and navigate to next step
    OnboardingLogger.logStepViewed(stepName: 'nickname', durationMs: 0);
    
    // Navigate to nickname step
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NicknameStepScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Welcome screen is step 0, progress is always 0%

    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Progress indicator (0%)
              ProgressIndicatorWidget(progress: 0.0),
              
              const Spacer(),
              
              // Speech bubble
              SpeechBubbleWidget(
                text: 'Chào mừng bạn đến với Ăn Khỏe!\nHãy cùng tôi tạo hồ sơ dinh dưỡng cá nhân nhé! 🎉',
                width: double.infinity,
              ),
              
              const SizedBox(height: 40),
              
              // Mascot
              const MascotWidget(
                size: 200,
                color: AppColors.mintGreen,
              ),
              
              const Spacer(),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onStartPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    foregroundColor: AppColors.nearBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bắt đầu',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.nearBlack,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: AppColors.nearBlack,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

