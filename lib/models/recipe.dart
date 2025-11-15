import 'food.dart';

class RecipeItem {
  final String foodId;
  final double grams;

  RecipeItem({required this.foodId, required this.grams});

  Map<String, dynamic> toMap() => {'foodId': foodId, 'grams': grams};

  factory RecipeItem.fromMap(Map<String, dynamic> m) => RecipeItem(
    foodId: m['foodId'] as String,
    grams: (m['grams'] as num).toDouble(),
  );
}

class Recipe {
  final String? id;
  final String name;
  final String? imageUrl;
  final List<RecipeItem> items;
  final int servings;
  final String? instructions;
  final String? authorId;
  final bool isApproved;
  final DateTime? createdAt;

  Recipe({
    this.id,
    required this.name,
    this.imageUrl,
    this.items = const [],
    this.servings = 1,
    this.instructions,
    this.authorId,
    this.isApproved = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'imageUrl': imageUrl,
    'items': items.map((e) => e.toMap()).toList(),
    'servings': servings,
    'instructions': instructions,
    'authorId': authorId,
    'isApproved': isApproved,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory Recipe.fromMap(String id, Map<String, dynamic> m) => Recipe(
    id: id,
    name: m['name'] as String? ?? '',
    imageUrl: m['imageUrl'] as String?,
    items:
        (m['items'] as List<dynamic>?)
            ?.map((e) => RecipeItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [],
    servings: (m['servings'] as num?)?.toInt() ?? 1,
    instructions: m['instructions'] as String?,
    authorId: m['authorId'] as String?,
    isApproved: m['isApproved'] as bool? ?? false,
    createdAt: m['createdAt'] == null
        ? null
        : DateTime.tryParse(m['createdAt'] as String),
  );

  /// compute total macros (kcal, protein, carb, fat) using a lookup function
  /// that maps foodId -> Food. The lookup may return null; missing foods are
  /// treated as zero.
  Map<String, double> computeMacros(Food? Function(String id) lookup) {
    double kcal = 0, protein = 0, carb = 0, fat = 0;
    for (final it in items) {
      final food = lookup(it.foodId);
      if (food == null) continue;
      final factor = it.grams / 100.0;
      kcal += (food.kcalPer100g * factor);
      protein += (food.proteinG * factor);
      carb += (food.carbG * factor);
      fat += (food.fatG * factor);
    }
    return {'kcal': kcal, 'protein': protein, 'carb': carb, 'fat': fat};
  }
}
