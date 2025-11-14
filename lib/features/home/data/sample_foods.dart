/// Dữ liệu mẫu cho các món ăn phổ biến
/// Giá trị dinh dưỡng được tính trên 100g
class SampleFood {
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double defaultServingGrams;

  const SampleFood({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.defaultServingGrams = 100.0,
  });
}

/// Danh sách món ăn mẫu phổ biến ở Việt Nam
class SampleFoods {
  static const List<SampleFood> all = [
    // Cơm và tinh bột
    SampleFood(
      name: 'Cơm trắng',
      caloriesPer100g: 130,
      proteinPer100g: 2.7,
      carbsPer100g: 28.2,
      fatPer100g: 0.3,
      defaultServingGrams: 150,
    ),
    SampleFood(
      name: 'Cơm gạo lứt',
      caloriesPer100g: 111,
      proteinPer100g: 2.6,
      carbsPer100g: 23.0,
      fatPer100g: 0.9,
      defaultServingGrams: 150,
    ),
    SampleFood(
      name: 'Phở bò',
      caloriesPer100g: 85,
      proteinPer100g: 4.5,
      carbsPer100g: 12.0,
      fatPer100g: 2.0,
      defaultServingGrams: 500,
    ),
    SampleFood(
      name: 'Bánh mì',
      caloriesPer100g: 265,
      proteinPer100g: 9.0,
      carbsPer100g: 49.0,
      fatPer100g: 3.2,
      defaultServingGrams: 100,
    ),

    // Thịt
    SampleFood(
      name: 'Thịt gà luộc',
      caloriesPer100g: 165,
      proteinPer100g: 31.0,
      carbsPer100g: 0.0,
      fatPer100g: 3.6,
      defaultServingGrams: 100,
    ),
    SampleFood(
      name: 'Thịt bò xào',
      caloriesPer100g: 250,
      proteinPer100g: 26.0,
      carbsPer100g: 0.0,
      fatPer100g: 15.0,
      defaultServingGrams: 100,
    ),
    SampleFood(
      name: 'Thịt heo nạc',
      caloriesPer100g: 143,
      proteinPer100g: 21.0,
      carbsPer100g: 0.0,
      fatPer100g: 6.0,
      defaultServingGrams: 100,
    ),

    // Cá và hải sản
    SampleFood(
      name: 'Cá hồi nướng',
      caloriesPer100g: 206,
      proteinPer100g: 22.0,
      carbsPer100g: 0.0,
      fatPer100g: 13.0,
      defaultServingGrams: 150,
    ),
    SampleFood(
      name: 'Tôm luộc',
      caloriesPer100g: 99,
      proteinPer100g: 24.0,
      carbsPer100g: 0.2,
      fatPer100g: 0.3,
      defaultServingGrams: 100,
    ),

    // Trứng
    SampleFood(
      name: 'Trứng gà luộc',
      caloriesPer100g: 155,
      proteinPer100g: 13.0,
      carbsPer100g: 1.1,
      fatPer100g: 11.0,
      defaultServingGrams: 50,
    ),
    SampleFood(
      name: 'Trứng chiên',
      caloriesPer100g: 196,
      proteinPer100g: 13.6,
      carbsPer100g: 0.8,
      fatPer100g: 15.0,
      defaultServingGrams: 50,
    ),

    // Rau củ
    SampleFood(
      name: 'Rau cải xào',
      caloriesPer100g: 35,
      proteinPer100g: 2.5,
      carbsPer100g: 5.0,
      fatPer100g: 0.5,
      defaultServingGrams: 100,
    ),
    SampleFood(
      name: 'Cà chua',
      caloriesPer100g: 18,
      proteinPer100g: 0.9,
      carbsPer100g: 3.9,
      fatPer100g: 0.2,
      defaultServingGrams: 100,
    ),
    SampleFood(
      name: 'Bông cải xanh',
      caloriesPer100g: 34,
      proteinPer100g: 2.8,
      carbsPer100g: 7.0,
      fatPer100g: 0.4,
      defaultServingGrams: 100,
    ),

    // Trái cây
    SampleFood(
      name: 'Chuối',
      caloriesPer100g: 89,
      proteinPer100g: 1.1,
      carbsPer100g: 23.0,
      fatPer100g: 0.3,
      defaultServingGrams: 120,
    ),
    SampleFood(
      name: 'Táo',
      caloriesPer100g: 52,
      proteinPer100g: 0.3,
      carbsPer100g: 14.0,
      fatPer100g: 0.2,
      defaultServingGrams: 150,
    ),
    SampleFood(
      name: 'Cam',
      caloriesPer100g: 47,
      proteinPer100g: 0.9,
      carbsPer100g: 12.0,
      fatPer100g: 0.1,
      defaultServingGrams: 150,
    ),

    // Đồ uống
    SampleFood(
      name: 'Sữa tươi',
      caloriesPer100g: 61,
      proteinPer100g: 3.2,
      carbsPer100g: 4.8,
      fatPer100g: 3.3,
      defaultServingGrams: 250,
    ),
    SampleFood(
      name: 'Sữa chua không đường',
      caloriesPer100g: 59,
      proteinPer100g: 10.0,
      carbsPer100g: 3.6,
      fatPer100g: 0.4,
      defaultServingGrams: 100,
    ),

    // Snacks
    SampleFood(
      name: 'Hạt hạnh nhân',
      caloriesPer100g: 579,
      proteinPer100g: 21.0,
      carbsPer100g: 22.0,
      fatPer100g: 50.0,
      defaultServingGrams: 30,
    ),
    SampleFood(
      name: 'Yến mạch',
      caloriesPer100g: 389,
      proteinPer100g: 17.0,
      carbsPer100g: 66.0,
      fatPer100g: 7.0,
      defaultServingGrams: 50,
    ),
  ];

  /// Tìm kiếm món ăn theo tên
  static List<SampleFood> search(String query) {
    if (query.isEmpty) return all;
    
    final lowerQuery = query.toLowerCase();
    return all.where((food) {
      return food.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Lấy món ăn theo category
  static List<SampleFood> getByCategory(String category) {
    // TODO: Implement category filtering
    return all;
  }
}

