import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calories_app/features/home/domain/meal_item.dart';
import 'package:calories_app/features/home/domain/meal_type.dart';

/// Bottom sheet để thêm/sửa món ăn
class AddMealItemBottomSheet extends StatefulWidget {
  final MealType mealType;
  final MealItem? existingItem; // null nếu thêm mới, có giá trị nếu edit

  const AddMealItemBottomSheet({
    super.key,
    required this.mealType,
    this.existingItem,
  });

  @override
  State<AddMealItemBottomSheet> createState() => _AddMealItemBottomSheetState();
}

class _AddMealItemBottomSheetState extends State<AddMealItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late TextEditingController _gramsPerServingController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  bool get isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _servingSizeController = TextEditingController(
      text: item?.servingSize.toString() ?? '1',
    );
    _gramsPerServingController = TextEditingController(
      text: item?.gramsPerServing.toString() ?? '100',
    );
    _caloriesController = TextEditingController(
      text: item?.caloriesPer100g.toString() ?? '',
    );
    _proteinController = TextEditingController(
      text: item?.proteinPer100g.toString() ?? '',
    );
    _carbsController = TextEditingController(
      text: item?.carbsPer100g.toString() ?? '',
    );
    _fatController = TextEditingController(
      text: item?.fatPer100g.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _gramsPerServingController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.mealType.color.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.mealType.icon,
                    color: widget.mealType.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Chỉnh sửa món ăn' : 'Thêm món ăn',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.mealType.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên món ăn
                    _buildTextField(
                      controller: _nameController,
                      label: 'Tên món ăn',
                      hint: 'Ví dụ: Cơm gạo lứt',
                      icon: Icons.restaurant,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên món ăn';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Khẩu phần và gram
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            controller: _servingSizeController,
                            label: 'Khẩu phần',
                            hint: '1',
                            suffix: 'phần',
                            icon: Icons.straighten,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberField(
                            controller: _gramsPerServingController,
                            label: 'Gram/phần',
                            hint: '100',
                            suffix: 'g',
                            icon: Icons.scale,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Thông tin dinh dưỡng (trên 100g)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                'Thông tin dinh dưỡng (trên 100g)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildNumberField(
                            controller: _caloriesController,
                            label: 'Calories',
                            hint: '130',
                            suffix: 'kcal',
                            icon: Icons.local_fire_department,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberField(
                                  controller: _proteinController,
                                  label: 'Protein',
                                  hint: '2.7',
                                  suffix: 'g',
                                  icon: Icons.egg,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildNumberField(
                                  controller: _carbsController,
                                  label: 'Carbs',
                                  hint: '28',
                                  suffix: 'g',
                                  icon: Icons.grain,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildNumberField(
                                  controller: _fatController,
                                  label: 'Fat',
                                  hint: '0.7',
                                  suffix: 'g',
                                  icon: Icons.water_drop,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.mealType.color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isEditing ? 'Cập nhật' : 'Thêm món',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Bắt buộc';
        }
        if (double.tryParse(value) == null) {
          return 'Không hợp lệ';
        }
        return null;
      },
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final item = MealItem(
        id: widget.existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        servingSize: double.parse(_servingSizeController.text),
        gramsPerServing: double.parse(_gramsPerServingController.text),
        caloriesPer100g: double.parse(_caloriesController.text),
        proteinPer100g: double.parse(_proteinController.text),
        carbsPer100g: double.parse(_carbsController.text),
        fatPer100g: double.parse(_fatController.text),
      );

      Navigator.pop(context, item);
    }
  }
}


