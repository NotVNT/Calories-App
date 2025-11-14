import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/number_picker_widget.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'current_weight_step_screen.dart';

class HeightStepScreen extends ConsumerStatefulWidget {
  const HeightStepScreen({super.key});

  @override
  ConsumerState<HeightStepScreen> createState() => _HeightStepScreenState();
}

class _HeightStepScreenState extends ConsumerState<HeightStepScreen> {
  int? _selectedHeight;
  bool _hasSelected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final onboardingState = ref.read(onboardingControllerProvider);
      setState(() {
        _selectedHeight = onboardingState.heightCm ?? 170; // Default to 170 cm
        _hasSelected = onboardingState.heightCm != null;
      });
    });
  }

  void _onHeightChanged(int height) {
    setState(() {
      _selectedHeight = height;
      _hasSelected = true;
    });
    ref.read(onboardingControllerProvider.notifier).updateHeight(height);
  }

  void _onContinuePressed() {
    if (_selectedHeight == null || !_hasSelected) return;

    // Navigate to weight step
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CurrentWeightStepScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      backgroundColor: AppColors.palePink,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bước 4/7'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 16.0,
            bottom: bottomPadding + 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Chiều cao của bạn',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chiều cao sẽ được sử dụng để tính chỉ số BMI và BMR.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              ProgressIndicatorWidget(
                progress: 4 / OnboardingModel.totalSteps,
              ),
              const SizedBox(height: 32),

              // Large height display
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.charmingGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_selectedHeight',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: AppColors.nearBlack,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'cm',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.mediumGray,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Picker widget
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: NumberPickerWidget(
                    min: 120,
                    max: 220,
                    initial: _selectedHeight ?? 170,
                    onChanged: _onHeightChanged,
                    suffix: 'cm',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasSelected ? _onContinuePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasSelected
                        ? AppColors.mintGreen
                        : AppColors.charmingGreen,
                    foregroundColor: AppColors.nearBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Tiếp tục',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.nearBlack,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

