import 'package:flutter/material.dart';
import 'package:calories_app/core/theme/theme.dart';

/// Custom height ruler widget for selecting height (120-220 cm)
class HeightRulerWidget extends StatefulWidget {
  final int initialHeight;
  final ValueChanged<int> onHeightChanged;
  final int minHeight;
  final int maxHeight;

  const HeightRulerWidget({
    super.key,
    required this.initialHeight,
    required this.onHeightChanged,
    this.minHeight = 120,
    this.maxHeight = 220,
  });

  @override
  State<HeightRulerWidget> createState() => _HeightRulerWidgetState();
}

class _HeightRulerWidgetState extends State<HeightRulerWidget> {
  late ScrollController _scrollController;
  late int _currentHeight;
  final double _itemHeight = 50.0;
  final int _visibleItems = 5;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.initialHeight.clamp(widget.minHeight, widget.maxHeight);
    final initialIndex = _currentHeight - widget.minHeight;
    final initialOffset = initialIndex * _itemHeight;
    
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
    final height = (index + widget.minHeight).clamp(widget.minHeight, widget.maxHeight);
    
    if (height != _currentHeight) {
      setState(() {
        _currentHeight = height;
      });
      widget.onHeightChanged(height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.maxHeight - widget.minHeight + 1;
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
              itemCount: itemCount,
              itemExtent: _itemHeight,
              itemBuilder: (context, index) {
                final height = widget.minHeight + index;
                final isSelected = height == _currentHeight;
                final isMajorTick = height % 10 == 0;
                final isMinorTick = height % 5 == 0;

                return _buildRulerItem(
                  height: height,
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
    required int height,
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
          
          // Height label (only for major ticks or selected)
          if (isMajorTick || isSelected)
            Text(
              '$height',
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
              'cm',
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


