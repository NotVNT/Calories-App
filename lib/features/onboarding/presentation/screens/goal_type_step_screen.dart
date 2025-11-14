import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'target_weight_step_screen.dart';

class GoalTypeStepScreen extends ConsumerStatefulWidget {
  const GoalTypeStepScreen({super.key});

  @override
  ConsumerState<GoalTypeStepScreen> createState() => _GoalTypeStepScreenState();
}

class _GoalTypeStepScreenState extends ConsumerState<GoalTypeStepScreen> {
  String? _selectedGoalType;

  @override
  void initState() {
    super.initState();
    final goalType = ref.read(onboardingControllerProvider).goalType;
    if (goalType == 'lose' || goalType == 'maintain' || goalType == 'gain') {
      _selectedGoalType = goalType;
    }
  }

  void _onSelectGoalType(String goalType) {
    setState(() {
      _selectedGoalType = goalType;
    });
    ref.read(onboardingControllerProvider.notifier).updateGoalType(goalType);
  }

  void _onContinue() {
    if (_selectedGoalType == null) return;

    // Navigate to target weight step
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TargetWeightStepScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bước 6/9'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Mục tiêu của bạn là gì?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chọn mục tiêu phù hợp với kế hoạch dinh dưỡng của bạn.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              ProgressIndicatorWidget(
                progress: 6 / OnboardingModel.totalSteps,
              ),
              const SizedBox(height: 32),

              // Goal type cards
              Expanded(
                child: Column(
                  children: [
                    _GoalTypeCard(
                      icon: Icons.trending_down,
                      title: 'Giảm cân',
                      description: 'Giảm cân một cách lành mạnh và bền vững',
                      isSelected: _selectedGoalType == 'lose',
                      onTap: () => _onSelectGoalType('lose'),
                    ),
                    const SizedBox(height: 16),
                    _GoalTypeCard(
                      icon: Icons.trending_flat,
                      title: 'Duy trì',
                      description: 'Duy trì cân nặng hiện tại của bạn',
                      isSelected: _selectedGoalType == 'maintain',
                      onTap: () => _onSelectGoalType('maintain'),
                    ),
                    const SizedBox(height: 16),
                    _GoalTypeCard(
                      icon: Icons.trending_up,
                      title: 'Tăng cân',
                      description: 'Tăng cân một cách lành mạnh',
                      isSelected: _selectedGoalType == 'gain',
                      onTap: () => _onSelectGoalType('gain'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedGoalType != null ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGoalType != null
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

class _GoalTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        AppColors.mintGreen.withOpacity(0.9),
        AppColors.mintGreen,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AnimatedContainer(
      duration: AppTheme.standardDuration,
      curve: AppTheme.standardEasing,
      decoration: BoxDecoration(
        gradient: isSelected ? gradient : null,
        color: isSelected ? null : AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : AppColors.charmingGreen,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.12 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.nearBlack.withOpacity(0.2)
                        : AppColors.mintGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isSelected
                        ? AppColors.nearBlack
                        : AppColors.mintGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isSelected
                                  ? AppColors.nearBlack
                                  : AppColors.nearBlack,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? AppColors.nearBlack.withOpacity(0.8)
                                  : AppColors.mediumGray,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.nearBlack,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

