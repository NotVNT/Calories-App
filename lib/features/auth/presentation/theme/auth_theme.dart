import 'package:flutter/material.dart';

class AuthTheme {
  static const Color mintGreen = Color(0xFFAAF0D1); 
  static const Color charmingGreen = Color(0xFFC3D3B7); 
  static const Color palePink = Color(0xFFF3E8EE); 
  static const Color nearBlack = Color(0xFF1A1A1A); 
  static const Color mediumGray = Color(0xFF666666); 

  static const double borderRadius = 18.0; 

  static const double buttonHeight = 56.0;

  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withAlpha((0.08 * 255).round()),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static TextStyle get headlineStyle => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: nearBlack,
        letterSpacing: -0.5,
      );

  static TextStyle get bodyStyle => const TextStyle(
        fontSize: 16,
        color: mediumGray,
        height: 1.5,
      );

  static TextStyle get buttonTextStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get linkTextStyle => const TextStyle(
        fontSize: 14,
        color: mintGreen,
        fontWeight: FontWeight.w600,
      );
}


