/// Weight units utility for handling weight in half-kilogram precision
/// This ensures consistent weight representation throughout the app
class WeightUnits {
  /// Convert kilograms to half-kilogram units (int)
  /// Example: 65.5 kg -> 131 half-kg units
  static int toHalfKg(double kg) => (kg * 2).round();

  /// Convert half-kilogram units to kilograms (double)
  /// Example: 131 half-kg units -> 65.5 kg
  static double fromHalfKg(int halfKg) => halfKg / 2.0;

  /// Format half-kilogram units as string with 1 decimal place
  /// Example: 131 -> "65.5"
  static String fmt(int halfKg) => fromHalfKg(halfKg).toStringAsFixed(1);

  /// Clamp weight in half-kg units to valid range (35.0 - 200.0 kg)
  static int clampHalfKg(int halfKg) {
    const minHalfKg = 70; // 35.0 kg
    const maxHalfKg = 400; // 200.0 kg
    return halfKg.clamp(minHalfKg, maxHalfKg);
  }

  /// Clamp weight in kg to valid range and convert to half-kg
  static int clampAndConvert(double kg) {
    const minKg = 35.0;
    const maxKg = 200.0;
    final clamped = kg.clamp(minKg, maxKg);
    return toHalfKg(clamped);
  }
}

