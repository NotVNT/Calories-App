import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'dob_step_screen.dart';

class GenderStepScreen extends ConsumerStatefulWidget {
  const GenderStepScreen({super.key});

  @override
  ConsumerState<GenderStepScreen> createState() => _GenderStepScreenState();
}

class _GenderStepScreenState extends ConsumerState<GenderStepScreen> {
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    final gender = ref.read(onboardingControllerProvider).gender;
    if (gender == 'male' || gender == 'female') {
      _selectedGender = gender;
    }
  }

  void _onSelectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    ref.read(onboardingControllerProvider.notifier).updateGender(gender);
  }

  void _onContinue() {
    if (_selectedGender == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DobStepScreen(),
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
        title: const Text('Bước 2/6'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Giới tính của bạn là?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chúng tôi sử dụng thông tin này để tính chỉ số BMR chính xác hơn.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              const ProgressIndicatorWidget(
                progress: 2 / OnboardingModel.totalSteps,
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      icon: Icons.male,
                      label: 'Nam',
                      isSelected: _selectedGender == 'male',
                      onTap: () => _onSelectGender('male'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _GenderCard(
                      icon: Icons.female,
                      label: 'Nữ',
                      isSelected: _selectedGender == 'female',
                      onTap: () => _onSelectGender('female'),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedGender != null ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGender != null
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

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
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
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: isSelected ? AppColors.nearBlack : AppColors.mintGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected
                            ? AppColors.nearBlack
                            : AppColors.nearBlack,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

