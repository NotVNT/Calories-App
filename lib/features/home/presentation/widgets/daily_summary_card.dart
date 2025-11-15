import 'package:flutter/material.dart';

/// Widget hiển thị tổng quan dinh dưỡng trong ngày
class DailySummaryCard extends StatelessWidget {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const DailySummaryCard({
    super.key,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAAF0D1), Color(0xFF7FD8BE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng quan ngày',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Hôm nay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientColumn(
                'Calo',
                totalCalories.toStringAsFixed(0),
                'kcal',
                Icons.local_fire_department,
              ),
              _buildDivider(),
              _buildNutrientColumn(
                'Protein',
                totalProtein.toStringAsFixed(1),
                'g',
                Icons.egg_outlined,
              ),
              _buildDivider(),
              _buildNutrientColumn(
                'Carbs',
                totalCarbs.toStringAsFixed(1),
                'g',
                Icons.grain,
              ),
              _buildDivider(),
              _buildNutrientColumn(
                'Fat',
                totalFat.toStringAsFixed(1),
                'g',
                Icons.water_drop_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientColumn(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withAlpha((0.9 * 255).round()),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: TextStyle(
            color: Colors.white.withAlpha((0.8 * 255).round()),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha((0.9 * 255).round()),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.white.withAlpha((0.3 * 255).round()),
    );
  }
}


