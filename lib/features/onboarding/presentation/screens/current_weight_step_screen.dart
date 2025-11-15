import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/core/utils/units/weight_units.dart';
import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'goal_type_step_screen.dart';

class CurrentWeightStepScreen extends ConsumerStatefulWidget {
  const CurrentWeightStepScreen({super.key});

  @override
  ConsumerState<CurrentWeightStepScreen> createState() => _CurrentWeightStepScreenState();
}

class _CurrentWeightStepScreenState extends ConsumerState<CurrentWeightStepScreen> {
  double? _selectedWeight;
  bool _hasSelected = false;

  @override
  void initState() {
    super.initState();
    // Defer provider reads to avoid modification during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final onboardingState = ref.read(onboardingControllerProvider);
      _selectedWeight = onboardingState.weightKgComputed ?? 65.0; // Default to 65 kg
      _hasSelected = onboardingState.weightKgComputed != null;
      setState(() {});
    });
  }

  void _onWeightChanged(double weight) {
    setState(() {
      _selectedWeight = weight;
      _hasSelected = true;
    });
    ref.read(onboardingControllerProvider.notifier).updateWeight(weight);
  }

  double? _calculateBMI() {
    final state = ref.read(onboardingControllerProvider);
    if (state.heightCm == null || _selectedWeight == null) {
      return null;
    }
    final heightInMeters = state.heightCm! / 100.0;
    return _selectedWeight! / (heightInMeters * heightInMeters);
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

  void _onContinuePressed() {
    if (_selectedWeight == null || !_hasSelected) return;

    // Navigate to goal type step
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GoalTypeStepScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _calculateBMI();
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.palePink,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bước 5/8'),
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
                'Cân nặng hiện tại',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cân nặng sẽ được sử dụng để tính chỉ số BMI và BMR.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              ProgressIndicatorWidget(
                progress: 5 / OnboardingModel.totalSteps,
              ),
              const SizedBox(height: 32),

              // Large weight display
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.charmingGreen.withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selectedWeight != null 
                            ? WeightUnits.fmt(WeightUnits.toHalfKg(_selectedWeight!))
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

              // BMI Card
              if (bmi != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(
                      color: _getBMIColor(bmi).withAlpha((0.3 * 255).round()),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).round()),
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
                            'Chỉ số BMI',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mediumGray,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bmi.toStringAsFixed(1),
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
                          color: _getBMIColor(bmi).withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          border: Border.all(
                            color: _getBMIColor(bmi),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _getBMILabel(bmi),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getBMIColor(bmi),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (bmi != null) const SizedBox(height: 24),

              // Picker widget - use fixed height container
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.05 * 255).round()),
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
                    initial: _selectedWeight ?? 65.0,
                    onChanged: (value) => _onWeightChanged(value),
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


