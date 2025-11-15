import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe.dart';
import '../models/food.dart';
import '../services/firebase_service.dart';
import 'foods_provider.dart';

class RecipesProvider extends ChangeNotifier {
  final FoodsProvider foodsProvider;
  final String? currentUserId;

  RecipesProvider({required this.foodsProvider, this.currentUserId}) {
    _init();
  }

  final Map<String, Recipe> _recipes = {};

  List<Recipe> get allRecipes => _recipes.values.toList(growable: false);

  /// Only show approved recipes or those authored by current user
  List<Recipe> visibleRecipes() {
    return allRecipes
        .where((r) {
          if (r.isApproved) return true;
          if (currentUserId != null && r.authorId == currentUserId) return true;
          return false;
        })
        .toList(growable: false);
  }

  Future<void> _init() async {
    // seed local foods if needed
    foodsProvider.seedSampleData();

    if (FirebaseService.shouldUseFirebase()) {
      await _loadFromFirestore();
    } else {
      seedSampleRecipes();
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('recipes').get();
      for (final d in snap.docs) {
        _recipes[d.id] = Recipe.fromMap(d.id, d.data());
      }
      notifyListeners();
    } catch (e) {
      // ignore and fall back
    }
  }

  /// Seed at least 6 sample recipes constructed from foods provider items.
  void seedSampleRecipes() {
    if (_recipes.isNotEmpty) return;
    final foods = foodsProvider.items;
    if (foods.isEmpty) return;

    List<Recipe> samples = [];

    // helper to pick by index safely
    Food? pick(int i) => i < foods.length ? foods[i] : null;

    samples.add(
      Recipe(
        id: 'r1',
        name: 'Phở bò đơn giản',
        items: [
          if (pick(0) != null) RecipeItem(foodId: pick(0)!.id, grams: 300),
        ],
        servings: 1,
        instructions: 'Nấu phở đơn giản từ nước dùng và gia vị.',
        isApproved: true,
      ),
    );

    samples.add(
      Recipe(
        id: 'r2',
        name: 'Bún chả ăn cùng rau',
        items: [
          if (pick(1) != null) RecipeItem(foodId: pick(1)!.id, grams: 250),
          if (pick(19) != null) RecipeItem(foodId: pick(19)!.id, grams: 50),
        ],
        servings: 2,
        instructions: 'Nướng thịt, ăn kèm bún và rau.',
      ),
    );

    samples.add(
      Recipe(
        id: 'r3',
        name: 'Bánh mì thịt',
        items: [
          if (pick(2) != null) RecipeItem(foodId: pick(2)!.id, grams: 150),
          if (pick(22) != null) RecipeItem(foodId: pick(22)!.id, grams: 50),
        ],
        servings: 1,
        instructions: 'Bánh mì kẹp thịt và đồ chua.',
        isApproved: true,
      ),
    );

    samples.add(
      Recipe(
        id: 'r4',
        name: 'Cơm tấm thập cẩm',
        items: [
          if (pick(3) != null) RecipeItem(foodId: pick(3)!.id, grams: 300),
          if (pick(24) != null) RecipeItem(foodId: pick(24)!.id, grams: 80),
        ],
        servings: 2,
        instructions: 'Cơm tấm ăn cùng sườn và chả.',
      ),
    );

    samples.add(
      Recipe(
        id: 'r5',
        name: 'Gỏi cuốn tươi mát',
        items: [
          if (pick(4) != null) RecipeItem(foodId: pick(4)!.id, grams: 120),
          if (pick(21) != null) RecipeItem(foodId: pick(21)!.id, grams: 30),
        ],
        servings: 4,
        instructions: 'Gói cuốn với rau sống và nước chấm.',
        isApproved: true,
      ),
    );

    samples.add(
      Recipe(
        id: 'r6',
        name: 'Chả giò chiên',
        items: [
          if (pick(9) != null) RecipeItem(foodId: pick(9)!.id, grams: 200),
        ],
        servings: 3,
        instructions: 'Chiên chả giò cho đến vàng giòn.',
      ),
    );

    for (final r in samples) {
      _recipes[r.id ?? UniqueKey().toString()] = r;
    }
    notifyListeners();
  }

  Future<String> createRecipe(Recipe recipe) async {
    if (FirebaseService.shouldUseFirebase()) {
      // Prevent accidental production writes
      FirebaseService.ensureCanWrite();
      final doc = await FirebaseFirestore.instance
          .collection('recipes')
          .add(recipe.toMap());
      final id = doc.id;
      _recipes[id] = Recipe.fromMap(id, recipe.toMap());
      notifyListeners();
      return id;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final copy = Recipe(
        id: id,
        name: recipe.name,
        imageUrl: recipe.imageUrl,
        items: recipe.items,
        servings: recipe.servings,
        instructions: recipe.instructions,
        authorId: recipe.authorId,
        isApproved: recipe.isApproved,
        createdAt: DateTime.now().toUtc(),
      );
      _recipes[id] = copy;
      notifyListeners();
      return id;
    }
  }

  Future<void> updateRecipe(String id, Recipe recipe) async {
    if (FirebaseService.shouldUseFirebase()) {
      // Prevent accidental production writes
      FirebaseService.ensureCanWrite();
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(id)
          .set(recipe.toMap());
      _recipes[id] = Recipe.fromMap(id, recipe.toMap());
      notifyListeners();
    } else {
      _recipes[id] = Recipe(
        id: id,
        name: recipe.name,
        imageUrl: recipe.imageUrl,
        items: recipe.items,
        servings: recipe.servings,
        instructions: recipe.instructions,
        authorId: recipe.authorId,
        isApproved: recipe.isApproved,
        createdAt: recipe.createdAt ?? DateTime.now().toUtc(),
      );
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String id) async {
    if (FirebaseService.shouldUseFirebase()) {
      // Prevent accidental production writes
      FirebaseService.ensureCanWrite();
      await FirebaseFirestore.instance.collection('recipes').doc(id).delete();
      _recipes.remove(id);
      notifyListeners();
    } else {
      _recipes.remove(id);
      notifyListeners();
    }
  }

  Recipe? getById(String id) => _recipes[id];

  /// Add recipe contents to diary. `servingsToAdd` is how many servings to add.
  /// This delegates to FoodsProvider.addToDiary for each ingredient scaled by
  /// servings.
  void addToDiary(String recipeId, int servingsToAdd) {
    final r = getById(recipeId);
    if (r == null) return;
    final factor = servingsToAdd / (r.servings > 0 ? r.servings : 1);
    for (final it in r.items) {
      final food = foodsProvider.items.firstWhere(
        (f) => f.id == it.foodId,
        orElse: () => Food(
          id: it.foodId,
          name: 'Unknown',
          kcalPer100g: 0,
          proteinG: 0,
          carbG: 0,
          fatG: 0,
          tags: [],
          imageUrl: null,
        ),
      );
      final gramsScaled = it.grams * factor;
      foodsProvider.addToDiary(food, gramsScaled);
    }
  }
}
