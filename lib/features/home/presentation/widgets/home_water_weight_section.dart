import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:calories_app/core/theme/theme.dart';
import '../providers/home_dashboard_providers.dart';

class HomeWaterWeightSection extends StatelessWidget {
  const HomeWaterWeightSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxWidth < 420;

        if (isVertical) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WaterCard(),
              SizedBox(height: 16),
              _WeightCard(),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _WaterCard()),
            SizedBox(width: 16),
            Expanded(child: _WeightCard()),
          ],
        );
      },
    );
  }
}

class _WaterCard extends ConsumerWidget {
  const _WaterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final water = ref.watch(homeWaterIntakeProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: AppColors.mintGreen,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Uống nước',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${water.totalMl} ml',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            'Mục tiêu ${water.goalMl} ml',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mediumGray,
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: water.progress,
              minHeight: 12,
              backgroundColor: AppColors.mintGreen.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mintGreen,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Quick add 250 ml water.
                  },
                  icon: const Icon(Icons.local_drink_outlined),
                  label: const Text('+250 ml'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.nearBlack,
                    side: const BorderSide(color: AppColors.charmingGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Quick add 500 ml water.
                  },
                  icon: const Icon(Icons.water),
                  label: const Text('+500 ml'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    foregroundColor: AppColors.nearBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightCard extends ConsumerWidget {
  const _WeightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(homeWeightHistoryProvider);
    final formatter = DateFormat('dd/MM', 'vi');

    final lastDateLabel = formatter.format(history.lastUpdated);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cân nặng gần nhất',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to weight update screen.
                },
                child: const Text('Cập nhật'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                history.lastWeight.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 6),
              Text(
                'kg',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mediumGray,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Cập nhật $lastDateLabel',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mediumGray,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _WeightTrendPainter(history.points),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(history.points.length, (index) {
                    final point = history.points[index];
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 90),
                          Text(
                            DateFormat('E', 'vi').format(point.date),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.mediumGray,
                                    ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightTrendPainter extends CustomPainter {
  _WeightTrendPainter(this.points);

  final List<WeightPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = AppColors.mintGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.mintGreen.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final minWeight = points
        .map((point) => point.weight)
        .reduce((value, element) => value < element ? value : element);
    final maxWeight = points
        .map((point) => point.weight)
        .reduce((value, element) => value > element ? value : element);

    final range = (maxWeight - minWeight).clamp(0.5, double.infinity);

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = size.width * (i / (points.length - 1));
      final normalized = (point.weight - minWeight) / range;
      final y = size.height - (normalized * size.height * 0.8) - size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.mintGreen);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

