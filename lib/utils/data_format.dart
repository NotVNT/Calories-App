String fmtCalories(num? kcal) {
  if (kcal == null) return '--';
  if (kcal == 0) return '0 cal';
  if (kcal.abs() >= 1000) return '${kcal.toStringAsFixed(0)} cal';
  return '${kcal.toStringAsFixed(0)} cal';
}

String fmtGrams(num? g) {
  if (g == null) return '--';
  if (g == 0) return '0 g';
  if (g >= 1000) return '${(g / 1000).toStringAsFixed(2)} kg';
  return '${g.toStringAsFixed(0)} g';
}

String fmtNullable(num? v, {int decimals = 0, String suffix = ''}) {
  if (v == null) return '--';
  return v.toStringAsFixed(decimals) + (suffix.isNotEmpty ? ' $suffix' : '');
}
