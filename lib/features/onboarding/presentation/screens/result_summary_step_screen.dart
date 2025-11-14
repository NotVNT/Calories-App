import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';
import 'package:intl/intl.dart';

import 'package:calories_app/features/onboarding/domain/nutrition_result.dart';
import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'macro_step_screen.dart';

class ResultSummaryStepScreen extends ConsumerStatefulWidget {
  const ResultSummaryStepScreen({super.key});

  @override
  ConsumerState<ResultSummaryStepScreen> createState() => _ResultSummaryStepScreenState();
}

class _ResultSummaryStepScreenState extends ConsumerState<ResultSummaryStepScreen> {
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
    final tdee = result.tdee;
    final targetKcal = result.targetKcal;
    final deficit = tdee - targetKcal; // Positive = deficit, Negative = surplus
    final goalDate = result.goalDate;

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
                'Kết quả tính toán',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.nearBlack,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dựa trên thông tin bạn đã cung cấp',
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

              // TDEE Card
              _TDEECard(tdee: tdee),
              const SizedBox(height: 16),

              // Deficit/Surplus Card
              _DeficitSurplusCard(
                deficit: deficit,
                goalType: goalType,
                tdee: tdee,
                targetKcal: targetKcal,
              ),
              const SizedBox(height: 16),

              // Goal Date Card (if applicable)
              if (goalDate != null && goalType != 'maintain')
                _GoalDateCard(goalDate: goalDate),
              if (goalDate != null && goalType != 'maintain')
                const SizedBox(height: 16),

              // Continue Button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to macro step
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MacroStepScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    foregroundColor: AppColors.nearBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Hoàn thành',
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

class _TDEECard extends StatelessWidget {
  final double tdee;

  const _TDEECard({required this.tdee});

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
                Text(
                  'TDEE/ngày',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.nearBlack,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                _InfoTooltip(
                  message: 'TDEE (Total Daily Energy Expenditure) là tổng năng lượng bạn đốt cháy mỗi ngày, bao gồm cả hoạt động thể chất.\n\nCông thức: TDEE = BMR × Hệ số hoạt động',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tdee.toStringAsFixed(0),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.nearBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'kcal',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.nearBlack.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeficitSurplusCard extends StatelessWidget {
  final double deficit;
  final String goalType;
  final double tdee;
  final double targetKcal;

  const _DeficitSurplusCard({
    required this.deficit,
    required this.goalType,
    required this.tdee,
    required this.targetKcal,
  });

  @override
  Widget build(BuildContext context) {
    final isDeficit = deficit > 0;
    final isMaintain = goalType == 'maintain';

    String title;
    String valueText;
    Color cardColor;

    if (isMaintain) {
      title = 'Duy trì cân nặng';
      valueText = '0';
      cardColor = AppColors.charmingGreen;
    } else if (isDeficit) {
      title = 'Thâm hụt calo';
      valueText = deficit.toStringAsFixed(0);
      cardColor = AppColors.mintGreen;
    } else {
      title = 'Dư thừa calo';
      valueText = deficit.abs().toStringAsFixed(0);
      cardColor = AppColors.mintGreen;
    }

    return Card(
      color: cardColor,
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.nearBlack,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                _InfoTooltip(
                  message: isMaintain
                      ? 'Để duy trì cân nặng, bạn cần ăn đúng bằng TDEE mỗi ngày.\n\nCalo mục tiêu = TDEE'
                      : isDeficit
                          ? 'Thâm hụt calo là lượng calo bạn ăn ít hơn TDEE để giảm cân.\n\nCông thức: Thâm hụt = TDEE - Calo mục tiêu\n\n~7700 kcal thâm hụt = giảm 1 kg'
                          : 'Dư thừa calo là lượng calo bạn ăn nhiều hơn TDEE để tăng cân.\n\nCông thức: Dư thừa = Calo mục tiêu - TDEE\n\n~7700 kcal dư thừa = tăng 1 kg',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valueText,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.nearBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                      ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'kcal',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.nearBlack.withOpacity(0.7),
                        ),
                  ),
                ),
              ],
            ),
            if (!isMaintain) ...[
              const SizedBox(height: 12),
              Divider(
                color: AppColors.nearBlack.withOpacity(0.2),
                thickness: 1,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TDEE',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.nearBlack.withOpacity(0.7),
                        ),
                  ),
                  Text(
                    '${tdee.toStringAsFixed(0)} kcal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.nearBlack,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calo mục tiêu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.nearBlack.withOpacity(0.7),
                        ),
                  ),
                  Text(
                    '${targetKcal.toStringAsFixed(0)} kcal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.nearBlack,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalDateCard extends StatelessWidget {
  final DateTime goalDate;

  const _GoalDateCard({required this.goalDate});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'vi');
    final formattedDate = dateFormat.format(goalDate);
    final today = DateTime.now();
    final daysUntilGoal = goalDate.difference(today).inDays;
    final weeksUntilGoal = (daysUntilGoal / 7).ceil();

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
                Text(
                  'Ngày dự kiến đạt mục tiêu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.nearBlack,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                _InfoTooltip(
                  message: 'Ngày dự kiến đạt mục tiêu được tính dựa trên:\n\n• Chênh lệch cân nặng hiện tại và mục tiêu\n• Tốc độ thay đổi cân nặng hàng tuần\n\nCông thức: Số tuần = |Cân nặng mục tiêu - Cân nặng hiện tại| / Tốc độ thay đổi (kg/tuần)',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.nearBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              weeksUntilGoal > 0
                  ? 'Còn khoảng $weeksUntilGoal tuần'
                  : 'Đã đạt mục tiêu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.nearBlack.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTooltip extends StatelessWidget {
  final String message;

  const _InfoTooltip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.nearBlack.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white,
          ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.mintGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thông tin',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.nearBlack,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                content: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.nearBlack,
                      ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Đóng',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.mintGreen,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.nearBlack.withOpacity(0.1),
            ),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.nearBlack.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

