import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/features/onboarding/data/services/nutrition_calculator.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'result_summary_step_screen.dart';

class CalculatingScreen extends ConsumerStatefulWidget {
  const CalculatingScreen({super.key});

  @override
  ConsumerState<CalculatingScreen> createState() => _CalculatingScreenState();
}

class _CalculatingScreenState extends ConsumerState<CalculatingScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Phân tích hồ sơ',
    'Tính trao đổi chất',
    'Tính calo mục tiêu',
  ];

  @override
  void initState() {
    super.initState();
    _startCalculation();
  }

  Future<void> _startCalculation() async {
    // Step 1: Analyze profile
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _currentStep = 1);
    }

    // Step 2: Calculate metabolism
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _currentStep = 2);
    }

    // Step 3: Calculate target calories
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _currentStep = 3);
    }

    // Calculate all nutrition values
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    try {
      final model = ref.read(onboardingControllerProvider);
      final result = NutritionCalculator.calculateAll(model);

      // Save result to state
      final controller = ref.read(onboardingControllerProvider.notifier);
      controller.saveResult(result.toMap());

      // Update model with calculated values using controller methods
      controller.updateBMRAndTDEE(result.bmr, result.tdee);
      controller.updateTargetKcal(result.targetKcal);
      controller.updateMacros(
        proteinPercent: result.proteinPercent,
        carbPercent: result.carbPercent,
        fatPercent: result.fatPercent,
      );

      // Navigate to result summary step
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ResultSummaryStepScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tính toán: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.palePink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading indicator
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.mintGreen),
                ),
              ),
              const SizedBox(height: 48),

              // Title
              const Text(
                'Đang tính toán...',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(height: 48),

              // Progress steps
              ...List.generate(_steps.length, (index) {
                final stepIndex = index + 1;
                final isCompleted = _currentStep > stepIndex;
                final isCurrent = _currentStep == stepIndex;
                final isPending = _currentStep < stepIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _CalculationStepRow(
                    label: _steps[index],
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isPending: isPending,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculationStepRow extends StatefulWidget {
  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPending;

  const _CalculationStepRow({
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPending,
  });

  @override
  State<_CalculationStepRow> createState() => _CalculationStepRowState();
}

class _CalculationStepRowState extends State<_CalculationStepRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.standardDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppTheme.standardEasing,
      ),
    );

    if (widget.isCurrent || widget.isCompleted) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_CalculationStepRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !oldWidget.isCurrent) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          // Status icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isCompleted
                  ? AppColors.mintGreen
                  : widget.isCurrent
                      ? AppColors.mintGreen.withAlpha((0.3 * 255).round())
                      : AppColors.charmingGreen.withAlpha((0.3 * 255).round()),
            ),
            child: widget.isCompleted
                ? const Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  )
                : widget.isCurrent
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.mintGreen,
                          ),
                        ),
                      )
                    : null,
          ),
          const SizedBox(width: 16),
          
          // Label
          Expanded(
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: widget.isPending
                        ? AppColors.mediumGray
                        : AppColors.nearBlack,
                    fontWeight: widget.isCurrent || widget.isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


