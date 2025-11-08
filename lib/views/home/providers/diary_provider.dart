import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../models/meal_type.dart';

/// Provider quản lý state của Diary với optimistic update
class DiaryProvider extends ChangeNotifier {
  // Map lưu trữ meals theo ngày (key: yyyy-MM-dd)
  final Map<String, List<Meal>> _mealsByDate = {};
  
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  String get _dateKey {
    return '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  // Lấy danh sách meals của ngày hiện tại
  List<Meal> get meals {
    if (!_mealsByDate.containsKey(_dateKey)) {
      // Khởi tạo 4 bữa ăn mặc định
      _mealsByDate[_dateKey] = [
        Meal(type: MealType.breakfast),
        Meal(type: MealType.lunch),
        Meal(type: MealType.dinner),
        Meal(type: MealType.snack),
      ];
    }
    return _mealsByDate[_dateKey]!;
  }

  // Lấy meal theo type
  Meal getMealByType(MealType type) {
    return meals.firstWhere((meal) => meal.type == type);
  }

  // Tính tổng dinh dưỡng trong ngày
  double get totalCalories =>
      meals.fold(0, (sum, meal) => sum + meal.totalCalories);

  double get totalProtein =>
      meals.fold(0, (sum, meal) => sum + meal.totalProtein);

  double get totalCarbs =>
      meals.fold(0, (sum, meal) => sum + meal.totalCarbs);

  double get totalFat =>
      meals.fold(0, (sum, meal) => sum + meal.totalFat);

  // Thêm món ăn vào bữa ăn (optimistic update)
  void addMealItem(MealType mealType, MealItem item) {
    final mealIndex = meals.indexWhere((meal) => meal.type == mealType);
    if (mealIndex != -1) {
      final updatedItems = List<MealItem>.from(meals[mealIndex].items)
        ..add(item);
      meals[mealIndex] = meals[mealIndex].copyWith(items: updatedItems);
      notifyListeners();
      
      // TODO: Lưu vào database ở đây (khi có database)
      _saveToDatabaseAsync(mealType, item);
    }
  }

  // Cập nhật món ăn (optimistic update)
  void updateMealItem(MealType mealType, String itemId, MealItem updatedItem) {
    final mealIndex = meals.indexWhere((meal) => meal.type == mealType);
    if (mealIndex != -1) {
      final itemIndex = meals[mealIndex].items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final updatedItems = List<MealItem>.from(meals[mealIndex].items);
        updatedItems[itemIndex] = updatedItem;
        meals[mealIndex] = meals[mealIndex].copyWith(items: updatedItems);
        notifyListeners();
        
        // TODO: Cập nhật database ở đây (khi có database)
        _updateInDatabaseAsync(mealType, updatedItem);
      }
    }
  }

  // Xóa món ăn (optimistic update)
  void deleteMealItem(MealType mealType, String itemId) {
    final mealIndex = meals.indexWhere((meal) => meal.type == mealType);
    if (mealIndex != -1) {
      final updatedItems = meals[mealIndex].items
          .where((item) => item.id != itemId)
          .toList();
      meals[mealIndex] = meals[mealIndex].copyWith(items: updatedItems);
      notifyListeners();
      
      // TODO: Xóa khỏi database ở đây (khi có database)
      _deleteFromDatabaseAsync(mealType, itemId);
    }
  }

  // Xóa tất cả món ăn trong một bữa
  void clearMeal(MealType mealType) {
    final mealIndex = meals.indexWhere((meal) => meal.type == mealType);
    if (mealIndex != -1) {
      meals[mealIndex] = meals[mealIndex].copyWith(items: []);
      notifyListeners();
      
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

