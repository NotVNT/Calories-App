import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/home/domain/meal.dart';
import 'package:calories_app/features/home/domain/meal_item.dart';
import 'package:calories_app/features/home/domain/meal_type.dart';

/// State class for Diary
class DiaryState {
  final Map<String, List<Meal>> mealsByDate;
  final DateTime selectedDate;

  const DiaryState({
    required this.mealsByDate,
    required this.selectedDate,
  });

  DiaryState copyWith({
    Map<String, List<Meal>>? mealsByDate,
    DateTime? selectedDate,
  }) {
    return DiaryState(
      mealsByDate: mealsByDate ?? this.mealsByDate,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// Provider quản lý state của Diary với optimistic update
class DiaryNotifier extends Notifier<DiaryState> {
  @override
  DiaryState build() {
    final today = _normalizeDate(DateTime.now());
    final dateKey = _getDateKey(today);
    return DiaryState(
      mealsByDate: {
        dateKey: _createDefaultMeals(),
      },
      selectedDate: today,
    );
  }

  DateTime get selectedDate => state.selectedDate;

  void setSelectedDate(DateTime date) {
    final normalized = _normalizeDate(date);
    final dateKey = _getDateKey(normalized);
    final hasEntry = state.mealsByDate.containsKey(dateKey);
    final updatedMealsByDate = hasEntry
        ? state.mealsByDate
        : {
            ...state.mealsByDate,
            dateKey: _createDefaultMeals(),
          };
    state = state.copyWith(
      selectedDate: normalized,
      mealsByDate: updatedMealsByDate,
    );
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Meal> _createDefaultMeals() {
    return [
      Meal(type: MealType.breakfast),
      Meal(type: MealType.lunch),
      Meal(type: MealType.dinner),
      Meal(type: MealType.snack),
    ];
  }

  void _ensureMealsForDate(DateTime date) {
    final dateKey = _getDateKey(date);
    if (!state.mealsByDate.containsKey(dateKey)) {
      final newMealsByDate = Map<String, List<Meal>>.from(state.mealsByDate);
      newMealsByDate[dateKey] = _createDefaultMeals();
      state = state.copyWith(mealsByDate: newMealsByDate);
    }
  }

  List<Meal> _currentMeals() {
    final dateKey = _getDateKey(state.selectedDate);
    return state.mealsByDate[dateKey]!;
  }

  // Lấy meal theo type
  Meal getMealByType(MealType type) {
    return _currentMeals().firstWhere((meal) => meal.type == type);
  }

  // Tính tổng dinh dưỡng trong ngày
  double get totalCalories =>
      _currentMeals().fold(0, (sum, meal) => sum + meal.totalCalories);

  double get totalProtein =>
      _currentMeals().fold(0, (sum, meal) => sum + meal.totalProtein);

  double get totalCarbs =>
      _currentMeals().fold(0, (sum, meal) => sum + meal.totalCarbs);

  double get totalFat =>
      _currentMeals().fold(0, (sum, meal) => sum + meal.totalFat);

  // Thêm món ăn vào bữa ăn (optimistic update)
  void addMealItem(MealType mealType, MealItem item) {
    final currentDate = state.selectedDate;
    _ensureMealsForDate(currentDate);
    final dateKey = _getDateKey(currentDate);
    final currentMeals = List<Meal>.from(_currentMeals());
    final mealIndex = currentMeals.indexWhere((meal) => meal.type == mealType);
    if (mealIndex != -1) {
      final updatedItems = List<MealItem>.from(currentMeals[mealIndex].items)
        ..add(item);
      currentMeals[mealIndex] = currentMeals[mealIndex].copyWith(items: updatedItems);
      
      final newMealsByDate = Map<String, List<Meal>>.from(state.mealsByDate);
      newMealsByDate[dateKey] = currentMeals;
      state = state.copyWith(mealsByDate: newMealsByDate);
      
      // TODO: Lưu vào database ở đây (khi có database)
      _saveToDatabaseAsync(mealType, item);
    }
  }

  // Cập nhật món ăn (optimistic update)
  void updateMealItem(MealType mealType, String itemId, MealItem updatedItem) {
    final currentDate = state.selectedDate;
    _ensureMealsForDate(currentDate);
    final dateKey = _getDateKey(currentDate);
    final currentMeals = List<Meal>.from(_currentMeals());
    final mealIndex = currentMeals.indexWhere((meal) => meal.type == mealType);
    if (mealIndex != -1) {
      final itemIndex = currentMeals[mealIndex].items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final updatedItems = List<MealItem>.from(currentMeals[mealIndex].items);
        updatedItems[itemIndex] = updatedItem;
        currentMeals[mealIndex] = currentMeals[mealIndex].copyWith(items: updatedItems);
        
        final newMealsByDate = Map<String, List<Meal>>.from(state.mealsByDate);
        newMealsByDate[dateKey] = currentMeals;
        state = state.copyWith(mealsByDate: newMealsByDate);
        
        // TODO: Cập nhật database ở đây (khi có database)
        _updateInDatabaseAsync(mealType, updatedItem);
      }
    }
  }

  // Xóa món ăn (optimistic update)
  void deleteMealItem(MealType mealType, String itemId) {
    final currentDate = state.selectedDate;
    _ensureMealsForDate(currentDate);
    final dateKey = _getDateKey(currentDate);
    final currentMeals = List<Meal>.from(_currentMeals());
    final mealIndex = currentMeals.indexWhere((meal) => meal.type == mealType);
    if (mealIndex != -1) {
      final updatedItems = currentMeals[mealIndex].items
          .where((item) => item.id != itemId)
          .toList();
      currentMeals[mealIndex] = currentMeals[mealIndex].copyWith(items: updatedItems);
      
      final newMealsByDate = Map<String, List<Meal>>.from(state.mealsByDate);
      newMealsByDate[dateKey] = currentMeals;
      state = state.copyWith(mealsByDate: newMealsByDate);
      
      // TODO: Xóa khỏi database ở đây (khi có database)
      _deleteFromDatabaseAsync(mealType, itemId);
    }
  }

  // Xóa tất cả món ăn trong một bữa
  void clearMeal(MealType mealType) {
    final currentDate = state.selectedDate;
    _ensureMealsForDate(currentDate);
    final dateKey = _getDateKey(currentDate);
    final currentMeals = List<Meal>.from(_currentMeals());
    final mealIndex = currentMeals.indexWhere((meal) => meal.type == mealType);
    if (mealIndex != -1) {
      currentMeals[mealIndex] = currentMeals[mealIndex].copyWith(items: []);
      
      final newMealsByDate = Map<String, List<Meal>>.from(state.mealsByDate);
      newMealsByDate[dateKey] = currentMeals;
      state = state.copyWith(mealsByDate: newMealsByDate);
      
      // TODO: Xóa khỏi database ở đây (khi có database)
      _clearMealInDatabaseAsync(mealType);
    }
  }

  // Placeholder methods cho database operations (sẽ implement sau)
  Future<void> _saveToDatabaseAsync(MealType mealType, MealItem item) async {
    // TODO: Implement database save
    if (kDebugMode) {
      print('Saving to database: ${item.name} in ${mealType.displayName}');
    }
  }

  Future<void> _updateInDatabaseAsync(MealType mealType, MealItem item) async {
    // TODO: Implement database update
    if (kDebugMode) {
      print('Updating in database: ${item.name} in ${mealType.displayName}');
    }
  }

  Future<void> _deleteFromDatabaseAsync(MealType mealType, String itemId) async {
    // TODO: Implement database delete
    if (kDebugMode) {
      print('Deleting from database: $itemId in ${mealType.displayName}');
    }
  }

  Future<void> _clearMealInDatabaseAsync(MealType mealType) async {
    // TODO: Implement database clear meal
    if (kDebugMode) {
      print('Clearing meal in database: ${mealType.displayName}');
    }
  }

  // Load dữ liệu từ database (sẽ implement sau)
  Future<void> loadMealsFromDatabase(DateTime date) async {
    // TODO: Implement database load
    if (kDebugMode) {
      print('Loading meals from database for date: $date');
    }
  }
}

/// Riverpod provider for Diary
final diaryProvider = NotifierProvider<DiaryNotifier, DiaryState>(() {
  return DiaryNotifier();
});

