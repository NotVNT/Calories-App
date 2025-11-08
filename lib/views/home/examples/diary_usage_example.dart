/// File này chứa các ví dụ về cách sử dụng Diary feature
/// Không dùng trong production, chỉ để tham khảo

import '../models/meal_item.dart';
import '../models/meal_type.dart';
import '../providers/diary_provider.dart';

/// Example 1: Tạo một món ăn mới
void createMealItemExample() {
  // Tạo món cơm trắng: 1.5 phần, mỗi phần 150g
  final rice = MealItem(
    id: '1',
    name: 'Cơm trắng',
    servingSize: 1.5, // 1.5 phần
    gramsPerServing: 150, // 150g mỗi phần
    caloriesPer100g: 130, // 130 kcal trên 100g
    proteinPer100g: 2.7,
    carbsPer100g: 28.2,
    fatPer100g: 0.3,
  );

  // Tính toán tự động:
  // totalGrams = 150 * 1.5 = 225g
  // totalCalories = (130 * 150 * 1.5) / 100 = 292.5 kcal
  print('Tổng gram: ${rice.totalGrams}g');
  print('Tổng calories: ${rice.totalCalories} kcal');
  print('Tổng protein: ${rice.totalProtein}g');
}

/// Example 2: Sử dụng DiaryProvider để thêm món ăn
void addMealItemExample() {
  final provider = DiaryProvider();

  // Tạo món gà luộc cho bữa trưa
  final chicken = MealItem(
    id: '2',
    name: 'Thịt gà luộc',
    servingSize: 1.0,
    gramsPerServing: 100,
    caloriesPer100g: 165,
    proteinPer100g: 31.0,
    carbsPer100g: 0.0,
    fatPer100g: 3.6,
  );

  // Thêm vào bữa trưa
  provider.addMealItem(MealType.lunch, chicken);

  // Kiểm tra tổng dinh dưỡng
  print('Tổng calories trong ngày: ${provider.totalCalories} kcal');
  print('Tổng protein trong ngày: ${provider.totalProtein}g');
}

/// Example 3: Cập nhật khẩu phần món ăn
void updateServingSizeExample() {
  final provider = DiaryProvider();

  // Thêm món ban đầu với 1 phần
  final banana = MealItem(
    id: '3',
    name: 'Chuối',
    servingSize: 1.0,
    gramsPerServing: 120,
    caloriesPer100g: 89,
    proteinPer100g: 1.1,
    carbsPer100g: 23.0,
    fatPer100g: 0.3,
  );

  provider.addMealItem(MealType.snack, banana);

  // Cập nhật thành 2 phần
  final updatedBanana = banana.copyWith(servingSize: 2.0);
  provider.updateMealItem(MealType.snack, banana.id, updatedBanana);

  // Calories sẽ tăng gấp đôi
  print('Calories sau khi tăng khẩu phần: ${updatedBanana.totalCalories} kcal');
}

/// Example 4: Tạo một bữa ăn hoàn chỉnh
void createCompleteMealExample() {
  final provider = DiaryProvider();

  // Bữa sáng: Bánh mì + Trứng + Sữa
  final breakfast = [
    MealItem(
      id: '4',
      name: 'Bánh mì',
      servingSize: 1.0,
      gramsPerServing: 100,
      caloriesPer100g: 265,
      proteinPer100g: 9.0,
      carbsPer100g: 49.0,
      fatPer100g: 3.2,
    ),
    MealItem(
      id: '5',
      name: 'Trứng gà luộc',
      servingSize: 2.0, // 2 quả
      gramsPerServing: 50, // 50g mỗi quả
      caloriesPer100g: 155,
      proteinPer100g: 13.0,
      carbsPer100g: 1.1,
      fatPer100g: 11.0,
    ),
    MealItem(
      id: '6',
      name: 'Sữa tươi',
      servingSize: 1.0,
      gramsPerServing: 250, // 1 ly = 250ml
      caloriesPer100g: 61,
      proteinPer100g: 3.2,
      carbsPer100g: 4.8,
      fatPer100g: 3.3,
    ),
  ];

  // Thêm tất cả món vào bữa sáng
  for (final item in breakfast) {
    provider.addMealItem(MealType.breakfast, item);
  }

  // Lấy thông tin bữa sáng
  final breakfastMeal = provider.getMealByType(MealType.breakfast);
  print('Bữa sáng có ${breakfastMeal.itemCount} món');
  print('Tổng calories bữa sáng: ${breakfastMeal.totalCalories} kcal');
  print('Tổng protein bữa sáng: ${breakfastMeal.totalProtein}g');
}

/// Example 5: Xóa món ăn
void deleteMealItemExample() {
  final provider = DiaryProvider();

  // Thêm món
  final snack = MealItem(
    id: '7',
    name: 'Kẹo',
    servingSize: 1.0,
    gramsPerServing: 30,
    caloriesPer100g: 400,
    proteinPer100g: 0.0,
    carbsPer100g: 95.0,
    fatPer100g: 2.0,
  );

  provider.addMealItem(MealType.snack, snack);
  print('Trước khi xóa: ${provider.totalCalories} kcal');

  // Xóa món
  provider.deleteMealItem(MealType.snack, snack.id);
  print('Sau khi xóa: ${provider.totalCalories} kcal');
}

/// Example 6: Chuyển đổi giữa các ngày
void changeDateExample() {
  final provider = DiaryProvider();

  // Ngày hôm nay
  print('Ngày hiện tại: ${provider.selectedDate}');

  // Chuyển sang ngày hôm qua
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  provider.setSelectedDate(yesterday);
  print('Ngày đã chọn: ${provider.selectedDate}');

  // Mỗi ngày có dữ liệu riêng
  // Khi chuyển ngày, meals sẽ load từ ngày đó
}

/// Example 7: Tính toán chi tiết dinh dưỡng
void nutritionCalculationExample() {
  // Ví dụ: Cơm gạo lứt
  // - 1.5 phần
  // - 150g mỗi phần
  // - 111 kcal trên 100g
  
  const servingSize = 1.5;
  const gramsPerServing = 150.0;
  const caloriesPer100g = 111.0;
  
  // Công thức:
  final totalGrams = gramsPerServing * servingSize;
  final totalCalories = (caloriesPer100g * gramsPerServing * servingSize) / 100;
  
  print('Tổng gram: $totalGrams g');
  print('Tổng calories: $totalCalories kcal');
  
  // Giải thích:
  // - 1 phần = 150g
  // - 1.5 phần = 150 * 1.5 = 225g
  // - 100g có 111 kcal
  // - 225g có (111 * 225) / 100 = 249.75 kcal
}

/// Example 8: Sử dụng copyWith để cập nhật
void copyWithExample() {
  final original = MealItem(
    id: '8',
    name: 'Salad',
    servingSize: 1.0,
    gramsPerServing: 200,
    caloriesPer100g: 50,
    proteinPer100g: 3.0,
    carbsPer100g: 8.0,
    fatPer100g: 1.0,
  );

  // Chỉ thay đổi khẩu phần, giữ nguyên các giá trị khác
  final updated = original.copyWith(servingSize: 1.5);
  
  print('Original: ${original.totalCalories} kcal');
  print('Updated: ${updated.totalCalories} kcal');
}

/// Example 9: Serialize/Deserialize (để lưu database)
void serializationExample() {
  final item = MealItem(
    id: '9',
    name: 'Phở bò',
    servingSize: 1.0,
    gramsPerServing: 500,
    caloriesPer100g: 85,
    proteinPer100g: 4.5,
    carbsPer100g: 12.0,
    fatPer100g: 2.0,
  );

  // Convert to JSON (để lưu vào database)
  final json = item.toJson();
  print('JSON: $json');

  // Convert from JSON (khi load từ database)
  final restored = MealItem.fromJson(json);
  print('Restored: ${restored.name} - ${restored.totalCalories} kcal');
}

/// Main function để chạy tất cả examples
void main() {
  print('=== Example 1: Create Meal Item ===');
  createMealItemExample();
  
  print('\n=== Example 2: Add Meal Item ===');
  addMealItemExample();
  
  print('\n=== Example 3: Update Serving Size ===');
  updateServingSizeExample();
  
  print('\n=== Example 4: Complete Meal ===');
  createCompleteMealExample();
  
  print('\n=== Example 5: Delete Meal Item ===');
  deleteMealItemExample();
  
  print('\n=== Example 6: Change Date ===');
  changeDateExample();
  
  print('\n=== Example 7: Nutrition Calculation ===');
  nutritionCalculationExample();
  
  print('\n=== Example 8: CopyWith ===');
  copyWithExample();
  
  print('\n=== Example 9: Serialization ===');
  serializationExample();
}

