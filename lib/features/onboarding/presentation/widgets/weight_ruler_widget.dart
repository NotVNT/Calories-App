import 'package:flutter/material.dart';
import 'package:calories_app/core/theme/theme.dart';

/// Custom weight ruler widget for selecting weight (35-200 kg, step 0.5)
class WeightRulerWidget extends StatefulWidget {
  final double initialWeight;
  final ValueChanged<double> onWeightChanged;
  final double minWeight;
  final double maxWeight;

  const WeightRulerWidget({
    super.key,
    required this.initialWeight,
    required this.onWeightChanged,
    this.minWeight = 35.0,
    this.maxWeight = 200.0,
  });

  @override
  State<WeightRulerWidget> createState() => _WeightRulerWidgetState();
}

class _WeightRulerWidgetState extends State<WeightRulerWidget> {
  late ScrollController _scrollController;
  late double _currentWeight;
  final double _itemHeight = 50.0;
  final int _visibleItems = 5;
  final double _step = 0.5;

  List<double> get _weights {
    final weights = <double>[];
    for (double w = widget.minWeight; w <= widget.maxWeight; w += _step) {
      weights.add(double.parse(w.toStringAsFixed(1)));
    }
    return weights;
  }

  @override
  void initState() {
    super.initState();
    _currentWeight = widget.initialWeight.clamp(widget.minWeight, widget.maxWeight);
    final weights = _weights;
    final initialIndex = weights.indexWhere((w) => (w - _currentWeight).abs() < 0.1);
    final initialOffset = (initialIndex >= 0 ? initialIndex : 0) * _itemHeight;
    
    _scrollController = ScrollController(
      initialScrollOffset: initialOffset,
    );
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final index = (offset / _itemHeight).round();
    final weights = _weights;
    if (index >= 0 && index < weights.length) {
      final weight = weights[index];
      if ((weight - _currentWeight).abs() > 0.1) {
        setState(() {
          _currentWeight = weight;
        });
        widget.onWeightChanged(weight);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weights = _weights;
    final centerOffset = (_visibleItems ~/ 2) * _itemHeight;

    return SizedBox(
      height: _itemHeight * _visibleItems,
      child: Stack(
        children: [
          // Ruler background
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: centerOffset),
              itemCount: weights.length,
              itemExtent: _itemHeight,
              itemBuilder: (context, index) {
                final weight = weights[index];
                final isSelected = (weight - _currentWeight).abs() < 0.1;
                final isMajorTick = weight % 10 == 0;
                final isMinorTick = weight % 5 == 0;

                return _buildRulerItem(
                  weight: weight,
                  isSelected: isSelected,
                  isMajorTick: isMajorTick,
                  isMinorTick: isMinorTick,
                );
              },
            ),
          ),
          
          // Selection indicator
          Center(
            child: Container(
              height: _itemHeight,
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: AppColors.mintGreen,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulerItem({
    required double weight,
    required bool isSelected,
    required bool isMajorTick,
    required bool isMinorTick,
  }) {
    return Container(
      height: _itemHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Tick marks
          Container(
            width: isMajorTick ? 40 : (isMinorTick ? 30 : 20),
            height: isMajorTick ? 2 : 1,
            color: isSelected
                ? AppColors.mintGreen
                : AppColors.charmingGreen.withAlpha((0.5 * 255).round()),
          ),
          const SizedBox(width: 16),
          
          // Weight label (only for major ticks or selected)
          if (isMajorTick || isSelected)
            Text(
              weight.toStringAsFixed(1),
              style: TextStyle(
                fontSize: isSelected ? 20 : 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.mintGreen
                    : AppColors.mediumGray,
              ),
            ),
          
          const Spacer(),
          
          // Unit label
          if (isSelected)
            Text(
              'kg',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.mediumGray,
              ),
            ),
        ],
      ),
    );
  }
}


