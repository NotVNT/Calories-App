import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'activity_level_step_screen.dart';

class WeeklyDeltaStepScreen extends ConsumerStatefulWidget {
  const WeeklyDeltaStepScreen({super.key});

  @override
  ConsumerState<WeeklyDeltaStepScreen> createState() => _WeeklyDeltaStepScreenState();
}

class _WeeklyDeltaStepScreenState extends ConsumerState<WeeklyDeltaStepScreen> {
  double _weeklyDelta = 0.5; // Default to recommended value
  final double _minDelta = 0.25;
  final double _maxDelta = 1.0;
  final double _step = 0.25;

  @override
  void initState() {
    super.initState();
    final onboardingState = ref.read(onboardingControllerProvider);
    _weeklyDelta = onboardingState.weeklyDeltaKg ?? 0.5;
    // Save initial value
    ref.read(onboardingControllerProvider.notifier).updateWeeklyDelta(_weeklyDelta);
  }

  void _onDeltaChanged(double value) {
    setState(() {
      _weeklyDelta = value;
    });
    ref.read(onboardingControllerProvider.notifier).updateWeeklyDelta(value);
  }

  double _calculateDailyDeltaKcal() {
    final goalType = ref.read(onboardingControllerProvider).goalType;
    if (goalType == null) return 0;
    
    // dailyDeltaKcal = weeklyDeltaKg * 7700 / 7
    final dailyDelta = _weeklyDelta * 7700 / 7;
    
    // Negative if losing weight
    return goalType == 'lose' ? -dailyDelta : dailyDelta;
  }

  String _getGoalTypeLabel() {
    final goalType = ref.read(onboardingControllerProvider).goalType;
    switch (goalType) {
      case 'lose':
        return 'Giảm';
      case 'gain':
        return 'Tăng';
      default:
        return '';
    }
  }

  void _onContinuePressed() {
    // Navigate to activity level step
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ActivityLevelStepScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalType = ref.read(onboardingControllerProvider).goalType;
    final dailyDeltaKcal = _calculateDailyDeltaKcal();
    final isRecommended = (_weeklyDelta - 0.5).abs() < 0.01;

    // Generate tick values
    final tickValues = <double>[];
    for (double i = _minDelta; i <= _maxDelta; i += _step) {
      tickValues.add(i);
    }

    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bước 8/11'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Tốc độ ${_getGoalTypeLabel()} cân',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chọn tốc độ ${goalType == 'lose' ? 'giảm' : 'tăng'} cân phù hợp với bạn',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              ProgressIndicatorWidget(
                progress: 8 / OnboardingModel.totalSteps,
              ),
              const SizedBox(height: 32),

              // Value display
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _weeklyDelta.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w700,
                              color: AppColors.nearBlack,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'kg/tuần',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.mediumGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (isRecommended) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mintGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                              color: AppColors.mintGreen,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Khuyến nghị',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mintGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Explanation text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppColors.charmingGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.mintGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '~7700 kcal cho 1 kg. Tốc độ ${_weeklyDelta.toStringAsFixed(2)} kg/tuần = ${dailyDeltaKcal.abs().toStringAsFixed(0)} kcal/ngày',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mediumGray,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Slider
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
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
                child: Column(
                  children: [
                    Slider(
                      value: _weeklyDelta,
                      min: _minDelta,
                      max: _maxDelta,
                      divisions: ((_maxDelta - _minDelta) / _step).toInt(),
                      label: '${_weeklyDelta.toStringAsFixed(2)} kg/tuần',
                      activeColor: AppColors.mintGreen,
                      inactiveColor: AppColors.charmingGreen.withOpacity(0.3),
                      onChanged: _onDeltaChanged,
                    ),
                    const SizedBox(height: 8),
                    // Tick labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: tickValues.map((value) {
                        final isSelected = (value - _weeklyDelta).abs() < 0.01;
                        final isRecommended = (value - 0.5).abs() < 0.01;
                        return Column(
                          children: [
                            if (isRecommended && !isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.mintGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '✓',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.mintGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (!isRecommended || isSelected) const SizedBox(height: 16),
                            Text(
                              value.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.mintGreen
                                    : AppColors.mediumGray,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onContinuePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
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

