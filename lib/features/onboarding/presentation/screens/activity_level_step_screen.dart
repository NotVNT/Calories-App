import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'calculating_screen.dart';

class ActivityLevelStepScreen extends ConsumerStatefulWidget {
  const ActivityLevelStepScreen({super.key});

  @override
  ConsumerState<ActivityLevelStepScreen> createState() => _ActivityLevelStepScreenState();
}

class _ActivityLevelStepScreenState extends ConsumerState<ActivityLevelStepScreen> {
  String? _selectedActivityLevel;
  int? _expandedIndex;

  final List<ActivityLevelData> _activityLevels = [
    ActivityLevelData(
      key: 'sedentary',
      title: 'Không tập luyện/Ít vận động',
      multiplier: 1.2,
      icon: Icons.chair,
      stepsPerDay: '< 5,000 bước',
      description: 'Ít hoặc không tập thể dục',
      exampleJobs: ['Nhân viên văn phòng', 'Lái xe', 'Làm việc tại nhà'],
    ),
    ActivityLevelData(
      key: 'light',
      title: 'Vận động nhẹ nhàng',
      multiplier: 1.375,
      icon: Icons.directions_walk,
      stepsPerDay: '5,000 - 7,500 bước',
      description: 'Tập thể dục nhẹ 1-3 ngày/tuần',
      exampleJobs: ['Giáo viên', 'Y tá', 'Bán hàng'],
    ),
    ActivityLevelData(
      key: 'moderate',
      title: 'Chăm chỉ luyện tập',
      multiplier: 1.55,
      icon: Icons.fitness_center,
      stepsPerDay: '7,500 - 10,000 bước',
      description: 'Tập thể dục vừa phải 3-5 ngày/tuần',
      exampleJobs: ['Công nhân xây dựng', 'Nhân viên kho', 'Bảo vệ'],
    ),
    ActivityLevelData(
      key: 'very_active',
      title: 'Rất năng động / Cực kỳ năng động',
      multiplier: 1.9,
      icon: Icons.sports_gymnastics,
      stepsPerDay: '> 12,500 bước',
      description: 'Tập thể dục rất nặng, lao động thể chất',
      exampleJobs: ['Vận động viên chuyên nghiệp', 'Công nhân nông nghiệp', 'Thợ mỏ'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    final activityLevel = ref.read(onboardingControllerProvider).activityLevel;
    if (activityLevel != null) {
      _selectedActivityLevel = activityLevel;
    }
  }

  void _onSelectActivityLevel(ActivityLevelData data) {
    setState(() {
      // Only one level can be selected
      _selectedActivityLevel = data.key;
      // Auto-expand the selected card
      final selectedIndex = _activityLevels.indexWhere((item) => item.key == data.key);
      if (selectedIndex != -1) {
        _expandedIndex = selectedIndex;
      }
    });
    // Update multiplier in controller
    ref.read(onboardingControllerProvider.notifier).updateActivityLevel(
          data.key,
          data.multiplier,
        );
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  void _onContinuePressed() {
    if (_selectedActivityLevel == null) return;

    // Navigate to calculating screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CalculatingScreen(),
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
        title: const Text('Bước 9/11'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Mức độ hoạt động',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chọn mức độ hoạt động phù hợp với lối sống của bạn',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              ProgressIndicatorWidget(
                progress: 9 / OnboardingModel.totalSteps,
              ),
              const SizedBox(height: 32),

              // Activity level list
              Expanded(
                child: ListView.builder(
                  itemCount: _activityLevels.length,
                  itemBuilder: (context, index) {
                    final data = _activityLevels[index];
                    final isSelected = _selectedActivityLevel == data.key;
                    final isExpanded = _expandedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ActivityLevelCard(
                        data: data,
                        isSelected: isSelected,
                        isExpanded: isExpanded,
                        onTap: () => _onSelectActivityLevel(data),
                        onExpand: () => _toggleExpand(index),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedActivityLevel != null ? _onContinuePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedActivityLevel != null
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

class ActivityLevelData {
  final String key;
  final String title;
  final double multiplier;
  final IconData icon;
  final String stepsPerDay;
  final String description;
  final List<String> exampleJobs;

  ActivityLevelData({
    required this.key,
    required this.title,
    required this.multiplier,
    required this.icon,
    required this.stepsPerDay,
    required this.description,
    required this.exampleJobs,
  });
}

class _ActivityLevelCard extends StatelessWidget {
  final ActivityLevelData data;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onExpand;

  const _ActivityLevelCard({
    required this.data,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    required this.onExpand,
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
              ? AppColors.mintGreen
              : AppColors.charmingGreen,
          width: isSelected ? 3 : 2,
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
          child: Column(
            children: [
              // Main card content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon at left
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.mintGreen.withOpacity(0.2)
                            : AppColors.charmingGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        data.icon,
                        color: isSelected
                            ? AppColors.mintGreen
                            : AppColors.charmingGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: isSelected
                                      ? AppColors.nearBlack
                                      : AppColors.nearBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? AppColors.nearBlack.withOpacity(0.8)
                                      : AppColors.mediumGray,
                                ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Expand button
                    GestureDetector(
                      onTap: () {
                        onExpand();
                      },
                      child: Icon(
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: isSelected
                            ? AppColors.nearBlack
                            : AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Expanded description
              if (isExpanded)
                AnimatedContainer(
                  duration: AppTheme.standardDuration,
                  curve: AppTheme.standardEasing,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: isSelected
                            ? AppColors.nearBlack.withOpacity(0.2)
                            : AppColors.charmingGreen.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      
                      // Steps per day
                      Row(
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 20,
                            color: isSelected
                                ? AppColors.nearBlack
                                : AppColors.mintGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data.stepsPerDay,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? AppColors.nearBlack
                                      : AppColors.nearBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Example jobs
                      Text(
                        'Ví dụ nghề nghiệp:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? AppColors.nearBlack.withOpacity(0.7)
                                  : AppColors.mediumGray,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: data.exampleJobs.map((job) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.nearBlack.withOpacity(0.1)
                                  : AppColors.charmingGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              job,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? AppColors.nearBlack
                                        : AppColors.nearBlack,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

