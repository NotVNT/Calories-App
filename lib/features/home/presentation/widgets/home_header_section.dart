import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:calories_app/core/theme/theme.dart';
import '../providers/home_dashboard_providers.dart';

class HomeHeaderSection extends ConsumerWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(homeSelectedDateProvider);
    final weekDays = _generateWeekDays(selectedDate);

    final dateLabel = DateFormat('EEEE, dd/MM', 'vi')
        .format(selectedDate)
        .replaceFirstMapped(RegExp(r'^\w'), (m) => m[0]!.toUpperCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hôm nay',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.mediumGray,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tổng quan',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.nearBlack,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          dateLabel,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mediumGray,
              ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 72,
          child: ListView.separated(
            padding: const EdgeInsets.only(right: 12),
            scrollDirection: Axis.horizontal,
            itemCount: weekDays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = weekDays[index];
              final isSelected = _isSameDate(date, selectedDate);
              final label = _weekdayLabel(date.weekday);
              final day = date.day;

              return GestureDetector(
                onTap: () =>
                    ref.read(homeSelectedDateProvider.notifier).select(date),
                child: SizedBox(
                  height: 60,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.mintGreen.withAlpha((0.9 * 255).round())
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? AppColors.mintGreen
                            : AppColors.charmingGreen.withAlpha((0.4 * 255).round()),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: isSelected
                                    ? AppColors.nearBlack
                                    : AppColors.mediumGray,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$day',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: isSelected
                                    ? AppColors.nearBlack
                                    : AppColors.mediumGray,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<DateTime> _generateWeekDays(DateTime selected) {
    final startOfWeek = selected.subtract(Duration(days: selected.weekday - 1));
    return List.generate(
      7,
      (index) {
        final current = startOfWeek.add(Duration(days: index));
        return DateTime(current.year, current.month, current.day);
      },
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }
}


