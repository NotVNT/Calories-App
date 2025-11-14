import 'package:flutter/material.dart';

/// App color constants
class AppColors {
  // Primary colors
  static const Color mintGreen = Color(0xFFAAF0D1); // Primary
  static const Color charmingGreen = Color(0xFFC3D3B7); // Secondary/Outline
  static const Color palePink = Color(0xFFF3E8EE); // Surface/Background

  // Text colors
  static const Color nearBlack = Color(0xFF1A1A1A); // Headline
  static const Color mediumGray = Color(0xFF666666); // Body text

  // Additional colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Error and success (if needed)
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF00C853);

  // Private constructor to prevent instantiation
  AppColors._();
}

/// Mint pie chart colors palette
class MintPieColors {
  static const List<Color> colors = [
    Color(0xFFAAF0D1), // Mint Green
    Color(0xFFC3D3B7), // Charming Green
    Color(0xFF95D5B2), // Light Mint
    Color(0xFF81C784), // Medium Green
    Color(0xFF66BB6A), // Green
    Color(0xFF4CAF50), // Material Green
    Color(0xFF81D4FA), // Light Blue
    Color(0xFF90CAF9), // Sky Blue
    Color(0xFFB39DDB), // Light Purple
    Color(0xFFA5D6A7), // Light Green
  ];

  // Get color by index with cycling
  static Color getColor(int index) {
    return colors[index % colors.length];
  }

  // Private constructor to prevent instantiation
  MintPieColors._();
}

