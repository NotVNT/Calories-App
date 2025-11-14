import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingTheme {
  // Color Palette
  static const Color primaryColor = Color(0xFFAAF0D1); // Mint Green
  static const Color secondaryColor = Color(0xFFC3D3B7); // Charming Green
  static const Color backgroundColor = Color(0xFFF3E8EE); // Pale Pink
  static const Color textColor = Color(0xFF2D3436); // Dark text for contrast
  static const Color lightTextColor = Color(0xFF636E72); // Light text
  static const Color whiteColor = Color(0xFFFFFFFF); // White

  // Typography
  static TextStyle get headingStyle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -0.5,
      );

  static TextStyle get subheadingStyle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
        height: 1.5,
      );

  static TextStyle get buttonTextStyle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: whiteColor,
        letterSpacing: 0.5,
      );

  static TextStyle get appNameStyle => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -0.5,
      );

  // Border Radius
  static const double borderRadius = 24.0;
  static const double buttonBorderRadius = 24.0;
  static const double cardBorderRadius = 20.0;
}


