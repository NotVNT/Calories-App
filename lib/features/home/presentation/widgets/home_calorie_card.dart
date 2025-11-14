import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calories_app/core/theme/theme.dart';
import '../providers/home_dashboard_providers.dart';

class HomeCalorieCard extends ConsumerWidget {
  const HomeCalorieCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeDailySummaryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final ringSize = isCompact ? 110.0 : 140.0;

        Widget content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _CalorieTextBlock(summary: summary)),
            SizedBox(width: isCompact ? 12 : 16),
            _CalorieProgressRing(
              summary: summary,
              diameter: ringSize,
            ),
          ],
        );

        if (isCompact) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CalorieTextBlock(summary: summary),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: _CalorieProgressRing(
                  summary: summary,
                  diameter: ringSize,
                ),
              ),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E2432),
                const Color(0xFF2A3040),
                AppColors.nearBlack.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: content,
        );
      },
    );
  }
}

class _CalorieTextBlock extends StatelessWidget {
  const _CalorieTextBlock({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mục tiêu calo',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          summary.remaining > 0 ? 'Còn lại' : 'Vượt mục tiêu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: summary.remaining > 0
                ? summary.remaining.toStringAsFixed(0)
                : summary.remaining.abs().toStringAsFixed(0),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
            children: const [
              TextSpan(
                text: ' kcal',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 28,
          runSpacing: 12,
          children: [
            _CalorieStat(
              label: 'Mục tiêu',
              value: summary.goal,
              color: Colors.white70,
            ),
            _CalorieStat(
              label: 'Đã nạp',
              value: summary.consumed,
              color: AppColors.mintGreen,
            ),
            _CalorieStat(
              label: 'Tập luyện',
              value: summary.burned,
              color: const Color(0xFF81D4FA),
            ),
          ],
        ),
      ],
    );
  }
}

class _CalorieStat extends StatelessWidget {
  const _CalorieStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white60,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)} kcal',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _CalorieProgressRing extends StatelessWidget {
  const _CalorieProgressRing({
    required this.summary,
    this.diameter = 140,
  });

  final DailySummary summary;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: diameter,
      width: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: diameter,
            width: diameter,
            child: CircularProgressIndicator(
              value: summary.progress,
              strokeWidth: 14,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.mintGreen),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.netIntake.toStringAsFixed(0),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'nạp ròng',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

