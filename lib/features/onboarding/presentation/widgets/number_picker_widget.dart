import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Reusable number picker widget using CupertinoPicker
class NumberPickerWidget extends StatelessWidget {
  final int min;
  final int max;
  final int initial;
  final ValueChanged<int> onChanged;
  final String? suffix;

  const NumberPickerWidget({
    super.key,
    required this.min,
    required this.max,
    required this.initial,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final controller = FixedExtentScrollController(
      initialItem: (initial - min).clamp(0, max - min),
    );

    return SizedBox(
      height: 220,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 44,
        useMagnifier: true,
        magnification: 1.05,
        diameterRatio: 1.2,
        onSelectedItemChanged: (index) {
          final value = min + index;
          onChanged(value);
        },
        children: List.generate(
          max - min + 1,
          (index) {
            final value = min + index;
            return Center(
              child: Text(
                suffix != null ? '$value $suffix' : '$value',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          },
        ),
      ),
    );
  }
}

