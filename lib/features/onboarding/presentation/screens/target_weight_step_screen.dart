import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/core/utils/units/weight_units.dart';
import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'activity_level_step_screen.dart';
import 'weekly_delta_step_screen.dart';

class TargetWeightStepScreen extends ConsumerStatefulWidget {
  const TargetWeightStepScreen({super.key});

  @override
  ConsumerState<TargetWeightStepScreen> createState() => _TargetWeightStepScreenState();
}

class _TargetWeightStepScreenState extends ConsumerState<TargetWeightStepScreen> {
  double? _selectedTargetWeight;
  bool _hasSelected = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Defer provider reads to avoid modification during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final onboardingState = ref.read(onboardingControllerProvider);
      final currentWeight = onboardingState.weightKgComputed ?? 65.0;
      final goalType = onboardingState.goalType;

      // Set initial target weight based on goal type
      if (onboardingState.targetWeightComputed != null) {
        _selectedTargetWeight = onboardingState.targetWeightComputed;
        _hasSelected = true;
      } else {
        switch (goalType) {
          case 'lose':
            _selectedTargetWeight = (currentWeight - 5).clamp(35.0, 200.0);
            break;
          case 'gain':
            _selectedTargetWeight = (currentWeight + 5).clamp(35.0, 200.0);
            break;
          case 'maintain':
            _selectedTargetWeight = currentWeight;
            break;
          default:
            _selectedTargetWeight = currentWeight;
        }
      }

      if (_selectedTargetWeight != null) {
        _validateTargetWeight(_selectedTargetWeight!);
        // Update provider after validation
        ref.read(onboardingControllerProvider.notifier).updateTargetWeight(_selectedTargetWeight!);
      }
      setState(() {});
    });
  }

  void _onWeightChanged(double weight) {
    // Debounce rapid updates
    if (_selectedTargetWeight != null && 
        (_selectedTargetWeight! - weight).abs() < 0.1) {
      return; // Skip if change is too small
    }
    
    setState(() {
      _selectedTargetWeight = weight;
      _hasSelected = true;
    });
    _validateTargetWeight(weight);
    // Update provider in next frame to avoid build-time modification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(onboardingControllerProvider.notifier).updateTargetWeight(weight);
      }
    });
  }

  void _validateTargetWeight(double targetWeight) {
    final state = ref.read(onboardingControllerProvider);
    final currentWeight = state.weightKgComputed;
    final goalType = state.goalType;

    if (currentWeight == null || goalType == null) {
      setState(() {
        _errorText = 'Vui lòng hoàn thành các bước trước';
        _hasSelected = false;
      });
      return;
    }

    String? error;
    bool isValid = true;

    switch (goalType) {
      case 'lose':
        if (targetWeight >= currentWeight) {
          error = 'Cân nặng mục tiêu phải nhỏ hơn cân nặng hiện tại';
          isValid = false;
        }
        break;
      case 'gain':
        if (targetWeight <= currentWeight) {
          error = 'Cân nặng mục tiêu phải lớn hơn cân nặng hiện tại';
          isValid = false;
        }
        break;
      case 'maintain':
        if ((targetWeight - currentWeight).abs() > 0.5) {
          error = 'Cân nặng mục tiêu phải gần bằng cân nặng hiện tại (±0.5 kg)';
          isValid = false;
        }
        break;
    }

    setState(() {
      _errorText = error;
      _hasSelected = isValid;
    });
  }

  double? _calculateTargetBMI() {
    final state = ref.read(onboardingControllerProvider);
    if (state.heightCm == null || _selectedTargetWeight == null) {
      return null;
    }
    final heightInMeters = state.heightCm! / 100.0;
    return _selectedTargetWeight! / (heightInMeters * heightInMeters);
  }

  String _getBMILabel(double bmi) {
    if (bmi < 18.5) {
      return 'Thiếu cân';
    } else if (bmi < 23) {
      return 'Bình thường';
    } else if (bmi < 25) {
      return 'Thừa cân';
    } else {
      return 'Béo phì';
    }
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.orange; // Warning
    } else if (bmi < 23) {
      return Colors.green; // Success
    } else if (bmi < 25) {
      return Colors.blue; // Info
    } else {
      return Colors.red; // Danger
    }
  }

  String _getGoalTypeLabel() {
    final goalType = ref.read(onboardingControllerProvider).goalType;
    switch (goalType) {
      case 'lose':
        return 'Giảm cân';
      case 'gain':
        return 'Tăng cân';
      case 'maintain':
        return 'Duy trì';
      default:
        return '';
    }
  }

  void _onContinuePressed() {
    // Validate before navigating
    if (_selectedTargetWeight == null || !_hasSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn cân nặng mục tiêu hợp lệ'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Additional validation: ensure weight is within valid range
    final weight = _selectedTargetWeight!;
    if (weight < 35.0 || weight > 200.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cân nặng mục tiêu phải trong khoảng 35-200 kg'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Re-validate against goal type rules
    final state = ref.read(onboardingControllerProvider);
    final currentWeight = state.weightKgComputed;
    final goalType = state.goalType;

    if (currentWeight != null && goalType != null) {
      bool isValid = true;
      String? errorMessage;

      switch (goalType) {
        case 'lose':
          if (weight >= currentWeight) {
            isValid = false;
            errorMessage = 'Cân nặng mục tiêu phải nhỏ hơn cân nặng hiện tại';
          }
          break;
        case 'gain':
          if (weight <= currentWeight) {
            isValid = false;
            errorMessage = 'Cân nặng mục tiêu phải lớn hơn cân nặng hiện tại';
          }
          break;
        case 'maintain':
          if ((weight - currentWeight).abs() > 0.5) {
            isValid = false;
            errorMessage = 'Cân nặng mục tiêu phải gần bằng cân nặng hiện tại (±0.5 kg)';
          }
          break;
      }

      if (!isValid && errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // All validations passed, navigate based on goal type
    if (goalType == 'maintain') {
      // Skip weekly delta step for maintain, go directly to activity step
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ActivityLevelStepScreen(),
        ),
      );
    } else {
      // Show weekly delta step for lose/gain
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const WeeklyDeltaStepScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.read(onboardingControllerProvider);
    final currentWeight = state.weightKgComputed ?? 0;
    final targetBMI = _calculateTargetBMI();
    
    // Fix closure bug: call the function to get the string value
    final goalTypeLabel = _getGoalTypeLabel();

    return Scaffold(
      backgroundColor: AppColors.palePink,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bước 7/10'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Cân nặng mong muốn',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.nearBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Mục tiêu: $goalTypeLabel. Cân nặng hiện tại: ${WeightUnits.fmt(WeightUnits.toHalfKg(currentWeight))} kg',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    ProgressIndicatorWidget(
                      progress: 7 / OnboardingModel.totalSteps,
                    ),
                    const SizedBox(height: 32),

                    // Large target weight display
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
                              _selectedTargetWeight != null
                                  ? WeightUnits.fmt(WeightUnits.toHalfKg(_selectedTargetWeight!))
                                  : '0.0',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w700,
                                color: AppColors.nearBlack,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'kg',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.mediumGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (_errorText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorText!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Target BMI Card
                    if (targetBMI != null && _hasSelected) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          border: Border.all(
                            color: _getBMIColor(targetBMI).withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BMI mục tiêu',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.mediumGray,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  targetBMI.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.nearBlack,
                                      ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getBMIColor(targetBMI).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                border: Border.all(
                                  color: _getBMIColor(targetBMI),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _getBMILabel(targetBMI),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getBMIColor(targetBMI),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Number picker wrapped in a fixed-size box
                    SizedBox(
                      height: 220,
                      child: Container(
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
                          child: _WeightPickerWidget(
                            min: 35,
                            max: 200,
                            initial: _selectedTargetWeight ?? 65.0,
                            onChanged: (value) => _onWeightChanged(value),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Continue button (not Expanded)
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Weight picker widget using CupertinoPicker (supports 0.5 kg steps)
class _WeightPickerWidget extends StatelessWidget {
  final int min;
  final int max;
  final double initial;
  final ValueChanged<double> onChanged;

  const _WeightPickerWidget({
    required this.min,
    required this.max,
    required this.initial,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // For weight, we need 0.5 kg steps, so we'll show integers but allow half values
    // We'll generate items for each 0.5 step: 35.0, 35.5, 36.0, ... 200.0
    final itemCount = ((max - min) * 2) + 1;
    final initialIndex = ((initial - min) * 2).round().clamp(0, itemCount - 1);
    
    final controller = FixedExtentScrollController(initialItem: initialIndex);

    return SizedBox(
      height: 220,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 44,
        useMagnifier: true,
        magnification: 1.05,
        diameterRatio: 1.2,
        onSelectedItemChanged: (index) {
          final value = min + (index / 2);
          onChanged(value);
        },
        children: List.generate(
          itemCount,
          (index) {
            final value = min + (index / 2);
            return Center(
              child: Text(
                '${WeightUnits.fmt(WeightUnits.toHalfKg(value))} kg',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          },
        ),
      ),
    );
  }
}

