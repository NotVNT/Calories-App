import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calories_app/core/theme/theme.dart';
import '../providers/home_dashboard_providers.dart';

class HomeActivitySection extends ConsumerWidget {
  const HomeActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(homeActivityCategoriesProvider);
    final summary = ref.watch(homeActivitySummaryProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.nearBlack.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.charmingGreen.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hoạt động tập luyện',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to activity history.
                },
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories
                .map(
                  (category) => ChoiceChip(
                    label: Text(category.label),
                    avatar: Icon(
                      category.icon,
                      size: 18,
                    ),
                    selected: false,
                    onSelected: (_) {
                      // TODO: Handle quick logging for activity.
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.mintGreen.withOpacity(0.9),
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isVertical = constraints.maxWidth < 420;
              if (isVertical) {
                return Column(
                  children: const [
                    _StepsCard(),
                    SizedBox(height: 16),
                    _WorkoutCard(),
                  ],
                );
              }

              return Row(
                children: const [
                  Expanded(child: _StepsCard()),
                  SizedBox(width: 16),
                  Expanded(child: _WorkoutCard()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            summary.stepsMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
          ),
        ],
      ),
    );
  }
}

class _StepsCard extends ConsumerWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeActivitySummaryProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.directions_walk,
                  color: Color(0xFF43A047),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bước chân',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary.stepsMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mediumGray,
                ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement connection to Google Fit / Health Connect.
            },
            icon: const Icon(Icons.link),
            label: const Text('Kết nối ngay'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.nearBlack,
              side: const BorderSide(color: AppColors.charmingGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends ConsumerWidget {
  const _WorkoutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeActivitySummaryProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF212531),
            Color(0xFF1B1F29),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tập luyện',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Add workout session logging.
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.mintGreen,
                ),
              ),
            ],
          ),
          Text(
            '${summary.workoutCalories} kcal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            'Đã đốt hôm nay',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

