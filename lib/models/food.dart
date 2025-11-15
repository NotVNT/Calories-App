import 'package:flutter/foundation.dart';

@immutable
class Food {
  final String id;
  final String name;
  final double kcalPer100g;
  final double proteinG;
  final double carbG;
  final double fatG;
  final List<String> tags;
  final String? imageUrl;

  const Food({
    required this.id,
    required this.name,
    required this.kcalPer100g,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    this.tags = const [],
    this.imageUrl,
  });

  factory Food.fromMap(Map<String, dynamic> m) => Food(
    id: m['id'] as String,
    name: m['name'] as String,
    kcalPer100g: (m['kcal_per_100g'] as num).toDouble(),
    proteinG: (m['protein_g'] as num).toDouble(),
    carbG: (m['carb_g'] as num).toDouble(),
    fatG: (m['fat_g'] as num).toDouble(),
    tags: (m['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    imageUrl: m['imageUrl'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'kcal_per_100g': kcalPer100g,
    'protein_g': proteinG,
    'carb_g': carbG,
    'fat_g': fatG,
    'tags': tags,
    'imageUrl': imageUrl,
  };
}
