import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_type.dart';
import '../models/meal_item.dart';
import '../providers/diary_provider.dart';
import '../widgets/meal_card.dart';
import '../widgets/add_meal_item_bottom_sheet.dart';
import '../widgets/daily_summary_card.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiaryProvider(),
      child: Consumer<DiaryProvider>(
        builder: (context, provider, child) {
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
                  onPressed: () => _selectDate(context, provider),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selector
                  _buildDateSelector(provider),
                  const SizedBox(height: 20),

                  // Daily Summary
                  _buildDailySummary(provider),
                  const SizedBox(height: 20),

                  // Meals Log
                  _buildMealsLog(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DiaryProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
    }
  }

  Widget _buildDateSelector(DiaryProvider provider) {
    final selectedDate = provider.selectedDate;
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
              provider.setSelectedDate(
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
                provider.setSelectedDate(
                  selectedDate.add(const Duration(days: 1)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary(DiaryProvider provider) {
    return DailySummaryCard(
      totalCalories: provider.totalCalories,
      totalProtein: provider.totalProtein,
      totalCarbs: provider.totalCarbs,
      totalFat: provider.totalFat,
    );
  }

  Widget _buildMealsLog(DiaryProvider provider) {
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
          final meal = provider.getMealByType(mealType);
          return MealCard(
            meal: meal,
            onAddItem: () => _showAddMealItemSheet(context, provider, mealType),
            onEditItem: (item) => _showEditMealItemSheet(
              context,
              provider,
              mealType,
              item,
            ),
            onDeleteItem: (itemId) => provider.deleteMealItem(mealType, itemId),
          );
        }),
      ],
    );
  }

  void _showAddMealItemSheet(
    BuildContext context,
    DiaryProvider provider,
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
        provider.addMealItem(mealType, result);
      }
    });
  }

  void _showEditMealItemSheet(
    BuildContext context,
    DiaryProvider provider,
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
        provider.updateMealItem(mealType, item.id, result);
      }
    });
  }
}

