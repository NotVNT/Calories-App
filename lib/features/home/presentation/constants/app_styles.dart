import 'package:flutter/material.dart';

class AppStyles {
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // Card Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withAlpha((0.05 * 255).round()),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: Colors.black54,
  );
  
  static TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
  );
}


