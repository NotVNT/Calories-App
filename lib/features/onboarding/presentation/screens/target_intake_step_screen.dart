import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:calories_app/data/firebase/profile_repository.dart';
import 'package:calories_app/features/home/presentation/screens/home_screen.dart';
import 'package:calories_app/features/onboarding/data/services/onboarding_logger.dart';
import 'package:calories_app/features/onboarding/data/services/onboarding_persistence_service.dart';
import 'package:calories_app/features/onboarding/domain/nutrition_result.dart';
import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/domain/profile_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';

class TargetIntakeStepScreen extends ConsumerStatefulWidget {
  const TargetIntakeStepScreen({super.key});

  @override
  ConsumerState<TargetIntakeStepScreen> createState() => _TargetIntakeStepScreenState();
}

class _TargetIntakeStepScreenState extends ConsumerState<TargetIntakeStepScreen> {
  final _profileRepository = ProfileRepository();
  final _auth = FirebaseAuth.instance;
  bool _isSaving = false;
  DateTime? _onboardingStartTime;

  Future<void> _handleSaveProfile() async {
    if (_isSaving) {
      debugPrint('[TargetIntakeStep] ⚠️ Save already in progress, ignoring duplicate call');
      return;
    }

    setState(() => _isSaving = true);
    debugPrint('[TargetIntakeStep] 🔵 Starting profile save process...');

    try {
      // Step 1: Ensure user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        debugPrint('[TargetIntakeStep] 👤 No current user, signing in anonymously...');
        final userCredential = await _auth.signInAnonymously();
        user = userCredential.user;
        if (user == null) {
          throw Exception('Không thể đăng nhập. Vui lòng thử lại.');
        }
      }
      
      final uid = user.uid;
      debugPrint('[TargetIntakeStep] ✅ User authenticated: uid=$uid');

      // Step 2: Get onboarding data
      final state = ref.read(onboardingControllerProvider);
      final resultMap = state.result;

      if (resultMap == null) {
        throw Exception('Không có dữ liệu kết quả. Vui lòng hoàn thành các bước trước.');
      }

      debugPrint('[TargetIntakeStep] 📊 Building profile from onboarding data...');
      final result = NutritionResult.fromMap(resultMap);

      // Step 3: Build ProfileModel
      final profile = ProfileModel.fromOnboarding(
        onboarding: state,
        result: result,
      );

      // Step 4: Convert to map
      final profileMap = profile.toMap();
      debugPrint('[TargetIntakeStep] 📋 Profile map created with ${profileMap.length} fields');

      // Step 5: Save profile with retry logic (max 3 attempts)
      String profileId;
      int retries = 3;
      Exception? lastError;

      while (retries > 0) {
        try {
          debugPrint('[TargetIntakeStep] 💾 Attempting to save profile (${4 - retries}/3)...');
          profileId = await _profileRepository.saveProfile(uid, profileMap);
          debugPrint('[TargetIntakeStep] ✅ Profile saved successfully: profileId=$profileId');
          break; // Success, exit retry loop
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          retries--;
          debugPrint('[TargetIntakeStep] ⚠️ Save attempt failed: $e ($retries retries remaining)');
          
          if (retries > 0) {
            // Exponential backoff: wait 1s, 2s, 4s
            final delaySeconds = 4 - retries;
            debugPrint('[TargetIntakeStep] ⏳ Waiting ${delaySeconds}s before retry...');
            await Future.delayed(Duration(seconds: delaySeconds));
          }
        }
      }

      if (retries == 0 && lastError != null) {
        throw lastError;
      }

      // Step 6: Clear draft after successful save
      debugPrint('[TargetIntakeStep] 🗑️ Clearing onboarding draft...');
      await OnboardingPersistenceService.clearDraft();
      debugPrint('[TargetIntakeStep] ✅ Draft cleared');

      // Step 7: Track onboarding completion
      if (_onboardingStartTime != null) {
        final totalDuration = DateTime.now().difference(_onboardingStartTime!);
        debugPrint('[TargetIntakeStep] 📈 Tracking onboarding completion (duration: ${totalDuration.inSeconds}s)');
        await OnboardingLogger.logOnboardingCompleted(
          stepName: 'target_intake',
          durationMs: totalDuration.inMilliseconds,
          totalSteps: 11,
        );
      }

      // Step 8: Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.white),
                SizedBox(width: 8),
                Text('Hồ sơ đã được lưu thành công!'),
              ],
            ),
            backgroundColor: AppColors.mintGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Step 9: Navigate to HomeScreen ONLY after all saves complete
        debugPrint('[TargetIntakeStep] 🏠 Navigating to HomeScreen...');
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
            (route) => false, // Remove all previous routes
          );
          debugPrint('[TargetIntakeStep] ✅ Navigation complete');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[TargetIntakeStep] 🔥 Profile save FAILED');
      debugPrint('[TargetIntakeStep] Error: $e');
      debugPrint('[TargetIntakeStep] Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() => _isSaving = false);

        // Show error snackbar with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lỗi: ${e.toString()}',
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: AppColors.white,
              onPressed: () => _handleSaveProfile(),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _onboardingStartTime = DateTime.now();
    // Track target intake step view
    OnboardingLogger.logStepViewed(stepName: 'target_intake', durationMs: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final resultMap = state.result;

    if (resultMap == null) {
      return Scaffold(
        backgroundColor: AppColors.palePink,
        body: const Center(
          child: Text('Không có dữ liệu kết quả'),
        ),
      );
    }

    final result = NutritionResult.fromMap(resultMap);
    final goalType = state.goalType ?? 'maintain';
    final targetKcal = result.targetKcal;
    final weeklyKcal = targetKcal * 7;
    final tdee = result.tdee;
    final deficit = tdee - targetKcal; // Positive = deficit, Negative = surplus

    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.nearBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Mục tiêu nạp calo',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.nearBlack,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lượng calo bạn cần nạp mỗi ngày và mỗi tuần',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mediumGray,
                    ),
              ),
              const SizedBox(height: 32),

              // Progress indicator
              ProgressIndicatorWidget(
                progress: 11 / OnboardingModel.totalSteps,
              ),
              const SizedBox(height: 32),

              // Two big Mint boxes - use fixed width instead of Expanded
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: _KcalBox(
                      label: 'kcal/ngày',
                      value: targetKcal,
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 1,
                    child: _KcalBox(
                      label: 'kcal/tuần',
                      value: weeklyKcal,
                      icon: Icons.date_range,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Breakdown cards
              _BreakdownCard(
                title: 'TDEE bạn cần nạp',
                value: tdee,
                unit: 'kcal/ngày',
                description: 'Tổng năng lượng bạn đốt cháy mỗi ngày',
                color: AppColors.mintGreen,
              ),
              const SizedBox(height: 16),

              if (goalType != 'maintain') ...[
                _BreakdownCard(
                  title: goalType == 'lose'
                      ? 'Calo thâm hụt'
                      : 'Calo dư thừa',
                  value: deficit.abs(),
                  unit: 'kcal/ngày',
                  description: goalType == 'lose'
                      ? 'Lượng calo bạn ăn ít hơn TDEE để giảm cân'
                      : 'Lượng calo bạn ăn nhiều hơn TDEE để tăng cân',
                  color: goalType == 'lose'
                      ? AppColors.mintGreen
                      : AppColors.charmingGreen,
                ),
                const SizedBox(height: 16),
              ],

              _BreakdownCard(
                title: 'Calo mục tiêu',
                value: targetKcal,
                unit: 'kcal/ngày',
                description: 'Lượng calo bạn cần nạp mỗi ngày để đạt mục tiêu',
                color: AppColors.charmingGreen,
              ),
              const SizedBox(height: 32),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSaveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    foregroundColor: AppColors.nearBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.nearBlack,
                            ),
                          ),
                        )
                      : Text(
                          'Bắt đầu hành trình',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.nearBlack,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KcalBox extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _KcalBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.mintGreen,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: AppColors.nearBlack,
                  size: 24,
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.nearBlack.withAlpha((0.7 * 255).round()),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value.toStringAsFixed(0),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.nearBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'kcal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.nearBlack.withAlpha((0.7 * 255).round()),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final String description;
  final Color color;

  const _BreakdownCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(
          color: AppColors.charmingGreen.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.nearBlack,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '${value.toStringAsFixed(0)} $unit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.nearBlack,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mediumGray,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


