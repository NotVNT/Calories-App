import 'package:flutter/material.dart';
import 'package:calories_app/features/home/domain/meal.dart';
import 'package:calories_app/features/home/domain/meal_item.dart';

/// Widget hiển thị một bữa ăn với danh sách món ăn
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onAddItem;
  final Function(MealItem) onEditItem;
  final Function(String) onDeleteItem;

  const MealCard({
    super.key,
    required this.meal,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: meal.items.isEmpty ? onAddItem : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: meal.type.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      meal.type.icon,
                      color: meal.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.type.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal.items.isEmpty
                              ? 'Chưa có món ăn'
                              : '${meal.totalCalories.toStringAsFixed(0)} kcal • ${meal.itemCount} món',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: meal.type.color,
                    ),
                    onPressed: onAddItem,
                  ),
                ],
              ),
            ),
          ),

          // Danh sách món ăn
          if (meal.items.isNotEmpty) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meal.items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final item = meal.items[index];
                return _buildMealItemTile(context, item);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealItemTile(BuildContext context, MealItem item) {
    return InkWell(
      onTap: () => onEditItem(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.totalGrams.toStringAsFixed(0)}g • '
                    '${item.totalCalories.toStringAsFixed(0)} kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildNutrientChip(
                        'P: ${item.totalProtein.toStringAsFixed(1)}g',
                        Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      _buildNutrientChip(
                        'C: ${item.totalCarbs.toStringAsFixed(1)}g',
                        Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      _buildNutrientChip(
                        'F: ${item.totalFat.toStringAsFixed(1)}g',
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MealItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

