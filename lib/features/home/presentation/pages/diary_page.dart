import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/home/domain/meal_item.dart';
import 'package:calories_app/features/home/domain/meal_type.dart';
import 'package:calories_app/features/home/presentation/providers/diary_provider.dart';
import 'package:calories_app/features/home/presentation/widgets/add_meal_item_bottom_sheet.dart';
import 'package:calories_app/features/home/presentation/widgets/daily_summary_card.dart';
import 'package:calories_app/features/home/presentation/widgets/meal_card.dart';

class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryProvider);
    final diaryNotifier = ref.read(diaryProvider.notifier);
    
    return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Nhật Ký',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.black87),
                  onPressed: () => _selectDate(context, diaryNotifier),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selector
                  _buildDateSelector(diaryNotifier, diaryState),
                  const SizedBox(height: 20),

                  // Daily Summary
                  _buildDailySummary(diaryNotifier),
                  const SizedBox(height: 20),

                  // Meals Log
                  _buildMealsLog(diaryNotifier),
                ],
              ),
            ),
          );
  }

  Future<void> _selectDate(BuildContext context, DiaryNotifier notifier) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: notifier.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != notifier.selectedDate) {
      notifier.setSelectedDate(picked);
    }
  }

  Widget _buildDateSelector(DiaryNotifier notifier, DiaryState state) {
    final selectedDate = state.selectedDate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              notifier.setSelectedDate(
                selectedDate.subtract(const Duration(days: 1)),
              );
            },
          ),
          Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              if (selectedDate.isBefore(DateTime.now())) {
                notifier.setSelectedDate(
                  selectedDate.add(const Duration(days: 1)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary(DiaryNotifier notifier) {
    return DailySummaryCard(
      totalCalories: notifier.totalCalories,
      totalProtein: notifier.totalProtein,
      totalCarbs: notifier.totalCarbs,
      totalFat: notifier.totalFat,
    );
  }

  Widget _buildMealsLog(DiaryNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bữa ăn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...MealType.values.map((mealType) {
          final meal = notifier.getMealByType(mealType);
          return MealCard(
            meal: meal,
            onAddItem: () => _showAddMealItemSheet(context, notifier, mealType),
            onEditItem: (item) => _showEditMealItemSheet(
              context,
              notifier,
              mealType,
              item,
            ),
            onDeleteItem: (itemId) => notifier.deleteMealItem(mealType, itemId),
          );
        }),
      ],
    );
  }

  void _showAddMealItemSheet(
    BuildContext context,
    DiaryNotifier notifier,
    MealType mealType,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddMealItemBottomSheet(mealType: mealType),
      ),
    ).then((result) {
      if (result != null && result is MealItem) {
        notifier.addMealItem(mealType, result);
      }
    });
  }

  void _showEditMealItemSheet(
    BuildContext context,
    DiaryNotifier notifier,
    MealType mealType,
    MealItem item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddMealItemBottomSheet(
          mealType: mealType,
          existingItem: item,
        ),
      ),
    ).then((result) {
      if (result != null && result is MealItem) {
        notifier.updateMealItem(mealType, item.id, result);
      }
    });
  }
}

