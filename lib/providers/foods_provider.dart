import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/food.dart';
import '../services/firebase_service.dart';

/// FoodsProvider holds a cache of Food items and provides search functionality.
/// It supports an in-memory fallback and has hooks to integrate with Firestore
/// when `FirebaseService.shouldUseFirebase()` returns true.
class FoodsProvider extends ChangeNotifier {
  final List<Food> _items = [];
  final List<String> _recentSearches = [];
  List<Food> _suggestions = [];
  Timer? _debounce;

  List<Food> get items => List.unmodifiable(_items);
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<Food> get suggestions => List.unmodifiable(_suggestions);

  /// Seed sample data (at least 30 VN items) into the local cache.
  /// If Firebase is enabled this could optionally push to Firestore.
  void seedSampleData() {
    if (_items.isNotEmpty) return;
    final sample = <Food>[
      Food(
        id: 'pho',
        name: 'Phở bò',
        kcalPer100g: 120,
        proteinG: 7,
        carbG: 10,
        fatG: 4,
        tags: ['soup'],
        imageUrl: null,
      ),
      Food(
        id: 'buncha',
        name: 'Bún chả',
        kcalPer100g: 210,
        proteinG: 10,
        carbG: 20,
        fatG: 10,
        tags: ['grill'],
        imageUrl: null,
      ),
      Food(
        id: 'banhmi',
        name: 'Bánh mì',
        kcalPer100g: 260,
        proteinG: 8,
        carbG: 45,
        fatG: 6,
        tags: ['bread'],
        imageUrl: null,
      ),
      Food(
        id: 'comtam',
        name: 'Cơm tấm',
        kcalPer100g: 200,
        proteinG: 7,
        carbG: 40,
        fatG: 3,
        tags: ['rice'],
        imageUrl: null,
      ),
      Food(
        id: 'goicuon',
        name: 'Gỏi cuốn',
        kcalPer100g: 95,
        proteinG: 3,
        carbG: 12,
        fatG: 2,
        tags: ['fresh'],
        imageUrl: null,
      ),
      Food(
        id: 'bunbo',
        name: 'Bún bò Huế',
        kcalPer100g: 150,
        proteinG: 8,
        carbG: 18,
        fatG: 5,
        tags: ['soup'],
        imageUrl: null,
      ),
      Food(
        id: 'chaoluc',
        name: 'Cháo lòng',
        kcalPer100g: 85,
        proteinG: 6,
        carbG: 12,
        fatG: 1,
        tags: ['porridge'],
        imageUrl: null,
      ),
      Food(
        id: 'ca',
        name: 'Cá kho',
        kcalPer100g: 180,
        proteinG: 20,
        carbG: 0,
        fatG: 10,
        tags: ['fish'],
        imageUrl: null,
      ),
      Food(
        id: 'ga',
        name: 'Gà luộc',
        kcalPer100g: 165,
        proteinG: 31,
        carbG: 0,
        fatG: 4,
        tags: ['chicken'],
        imageUrl: null,
      ),
      Food(
        id: 'cha',
        name: 'Chả giò',
        kcalPer100g: 250,
        proteinG: 6,
        carbG: 30,
        fatG: 10,
        tags: ['fried'],
        imageUrl: null,
      ),
      Food(
        id: 'xoi',
        name: 'Xôi',
        kcalPer100g: 200,
        proteinG: 5,
        carbG: 45,
        fatG: 2,
        tags: ['rice'],
        imageUrl: null,
      ),
      Food(
        id: 'bunthitnuong',
        name: 'Bún thịt nướng',
        kcalPer100g: 230,
        proteinG: 9,
        carbG: 28,
        fatG: 8,
        tags: ['grill'],
        imageUrl: null,
      ),
      Food(
        id: 'canh',
        name: 'Canh chua',
        kcalPer100g: 40,
        proteinG: 2,
        carbG: 6,
        fatG: 1,
        tags: ['soup'],
        imageUrl: null,
      ),
      Food(
        id: 'nem',
        name: 'Nem rán',
        kcalPer100g: 240,
        proteinG: 7,
        carbG: 28,
        fatG: 9,
        tags: ['fried'],
        imageUrl: null,
      ),
      Food(
        id: 'bot',
        name: 'Bột chiên',
        kcalPer100g: 260,
        proteinG: 6,
        carbG: 33,
        fatG: 11,
        tags: ['street'],
        imageUrl: null,
      ),
      Food(
        id: 'che',
        name: 'Chè',
        kcalPer100g: 150,
        proteinG: 2,
        carbG: 30,
        fatG: 2,
        tags: ['dessert'],
        imageUrl: null,
      ),
      Food(
        id: 'banhcuon',
        name: 'Bánh cuốn',
        kcalPer100g: 140,
        proteinG: 4,
        carbG: 22,
        fatG: 3,
        tags: ['rice'],
        imageUrl: null,
      ),
      Food(
        id: 'banhxeo',
        name: 'Bánh xèo',
        kcalPer100g: 270,
        proteinG: 8,
        carbG: 28,
        fatG: 12,
        tags: ['pan'],
        imageUrl: null,
      ),
      Food(
        id: 'rau',
        name: 'Rau luộc',
        kcalPer100g: 25,
        proteinG: 2,
        carbG: 5,
        fatG: 0,
        tags: ['veg'],
        imageUrl: null,
      ),
      Food(
        id: 'mut',
        name: 'Mứt',
        kcalPer100g: 300,
        proteinG: 0,
        carbG: 75,
        fatG: 0,
        tags: ['sweet'],
        imageUrl: null,
      ),
      Food(
        id: 'sua',
        name: 'Sữa chua',
        kcalPer100g: 60,
        proteinG: 3,
        carbG: 8,
        fatG: 1,
        tags: ['dairy'],
        imageUrl: null,
      ),
      Food(
        id: 'thitbo',
        name: 'Thịt bò',
        kcalPer100g: 250,
        proteinG: 26,
        carbG: 0,
        fatG: 15,
        tags: ['beef'],
        imageUrl: null,
      ),
      Food(
        id: 'thitheo',
        name: 'Thịt heo',
        kcalPer100g: 242,
        proteinG: 25,
        carbG: 0,
        fatG: 14,
        tags: ['pork'],
        imageUrl: null,
      ),
      Food(
        id: 'dua',
        name: 'Dưa leo',
        kcalPer100g: 15,
        proteinG: 0.7,
        carbG: 3,
        fatG: 0,
        tags: ['veg'],
        imageUrl: null,
      ),
      Food(
        id: 'trung',
        name: 'Trứng luộc',
        kcalPer100g: 155,
        proteinG: 13,
        carbG: 1,
        fatG: 11,
        tags: ['egg'],
        imageUrl: null,
      ),
      Food(
        id: 'sushi',
        name: 'Sushi (viet style)',
        kcalPer100g: 130,
        proteinG: 5,
        carbG: 20,
        fatG: 2,
        tags: ['rice'],
        imageUrl: null,
      ),
      Food(
        id: 'muc',
        name: 'Mực nướng',
        kcalPer100g: 95,
        proteinG: 15,
        carbG: 1,
        fatG: 2,
        tags: ['seafood'],
        imageUrl: null,
      ),
      Food(
        id: 'tom',
        name: 'Tôm',
        kcalPer100g: 99,
        proteinG: 24,
        carbG: 0,
        fatG: 0.3,
        tags: ['seafood'],
        imageUrl: null,
      ),
    ];

    _items.addAll(sample);
    notifyListeners();
  }

  /// Search local cache immediately and schedule a remote refresh after 200ms.
  /// Returns immediate results (fast path). The provider will update
  /// [suggestions] after remote fetch completes.
  List<Food> search(String term, {int limit = 10}) {
    final q = term.trim().toLowerCase();
    if (q.isEmpty) return [];

    // local quick filter
    final local = _items
        .where((f) => f.name.toLowerCase().contains(q))
        .take(limit)
        .toList();

    // schedule remote refresh
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      if (FirebaseService.shouldUseFirebase()) {
        try {
          // TODO: implement Firestore fetch when available
          // For now remote == local in this shim implementation
          _suggestions = local;
        } catch (e) {
          _suggestions = local;
        }
      } else {
        _suggestions = local;
      }
      notifyListeners();
    });

    // set immediate suggestions (fast UI response)
    _suggestions = local;
    notifyListeners();
    return local;
  }

  /// Add to recent searches
  void addRecentSearch(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    _recentSearches.remove(t);
    _recentSearches.insert(0, t);
    if (_recentSearches.length > 10) _recentSearches.removeLast();
    notifyListeners();
  }

  /// Group items by first tag for list screen
  Map<String, List<Food>> groupedByTag() {
    final map = <String, List<Food>>{};
    for (final f in _items) {
      final tag = f.tags.isNotEmpty ? f.tags.first : 'Other';
      map.putIfAbsent(tag, () => []).add(f);
    }
    return map;
  }

  // Diary in-memory store
  final List<Map<String, dynamic>> _diary = [];

  void addToDiary(Food food, double grams) {
    final kcal = (food.kcalPer100g / 100.0) * grams;
    _diary.add({
      'foodId': food.id,
      'name': food.name,
      'grams': grams,
      'kcal': kcal,
      'time': DateTime.now().toUtc(),
    });
    notifyListeners();
  }

  List<Map<String, dynamic>> get diary => List.unmodifiable(_diary);
}
