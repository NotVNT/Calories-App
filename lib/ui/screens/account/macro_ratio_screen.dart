// ignore_for_file: use_build_context_synchronously

import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';
import 'diet_mode_screen.dart';

class MacroRatioScreen extends StatefulWidget {
  const MacroRatioScreen({super.key});

  @override
  State<MacroRatioScreen> createState() => _MacroRatioScreenState();
}

class _MacroRatioScreenState extends State<MacroRatioScreen> {
  double protein = 0.20;
  double carbs = 0.50;
  double fat = 0.30;

  void _normalizeExcept(String changed) {
    // ensure sum == 1.0 by scaling the other two to fill remaining
    final total = protein + carbs + fat;
    if ((total - 1.0).abs() < 0.0001) return;
    if (changed == 'protein') {
      final remain = (1.0 - protein).clamp(0.0, 1.0);
      final other = carbs + fat;
      if (other <= 0) {
        carbs = remain * 0.5;
        fat = remain * 0.5;
      } else {
        final scale = remain / other;
        carbs = (carbs * scale).clamp(0.0, remain);
        fat = (fat * scale).clamp(0.0, remain);
      }
    } else if (changed == 'carbs') {
      final remain = (1.0 - carbs).clamp(0.0, 1.0);
      final other = protein + fat;
      if (other <= 0) {
        protein = remain * 0.5;
        fat = remain * 0.5;
      } else {
        final scale = remain / other;
        protein = (protein * scale).clamp(0.0, remain);
        fat = (fat * scale).clamp(0.0, remain);
      }
    } else {
      final remain = (1.0 - fat).clamp(0.0, 1.0);
      final other = protein + carbs;
      if (other <= 0) {
        protein = remain * 0.5;
        carbs = remain * 0.5;
      } else {
        final scale = remain / other;
        protein = (protein * scale).clamp(0.0, remain);
        carbs = (carbs * scale).clamp(0.0, remain);
      }
    }
    setState(() {});
  }

  int _grams(double pct, int calories, int kcalPerGram) {
    if (calories <= 0) return 0;
    final kcal = calories * pct;
    return (kcal / kcalPerGram).round();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final calorieTarget = profile.calorieTarget ?? 1752;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tỷ lệ dinh dưỡng đa lượng')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Ring showing 100% (responsive size)
          Builder(
            builder: (ctx) {
              final availableWidth =
                  MediaQuery.of(ctx).size.width - 32; // list padding
              final cpSize = min(120.0, availableWidth * 0.5);
              final stroke = (cpSize * 0.12).clamp(8.0, 20.0);
              return SizedBox(
                height: cpSize + 12,
                child: Center(
                  child: CustomPaint(
                    size: Size(cpSize, cpSize),
                    painter: _MacroPainter(
                      protein,
                      carbs,
                      fat,
                      theme.colorScheme,
                      stroke,
                    ),
                    child: Center(
                      child: Text(
                        '100%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Vòng tròn đa lượng phải bằng 100%',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 18),

          // Diet mode button -> open full selection screen
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Builder(
              builder: (ctx) {
                final goal = profile.goal;
                String dietLabel = 'Tùy chỉnh';
                if (goal.startsWith('diet:')) {
                  final parts = goal.split(':');
                  final key = parts.length > 1 ? parts[1] : '';
                  if (key == 'high_protein') {
                    dietLabel = 'Ít tinh bột - Tăng đạm';
                  }
                  if (key == 'keto') {
                    dietLabel = 'Keto';
                  }
                  if (key == 'balanced') {
                    dietLabel = 'Cân bằng';
                  }
                }

                return ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: const Text('Chế độ ăn'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(dietLabel),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () =>
                      Navigator.push<bool?>(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => const DietModeScreen(),
                        ),
                      ).then((res) {
                        if (res == true) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Cập nhật chế độ ăn thành công'),
                            ),
                          );
                        }
                      }),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Sliders card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  _macroRow(
                    context,
                    'Chất đạm',
                    protein,
                    Colors.red,
                    calorieTarget,
                    4,
                  ),
                  const Divider(height: 1),
                  _macroRow(
                    context,
                    'Đường bột',
                    carbs,
                    Colors.blue,
                    calorieTarget,
                    4,
                  ),
                  const Divider(height: 1),
                  _macroRow(
                    context,
                    'Chất béo',
                    fat,
                    Colors.amber,
                    calorieTarget,
                    9,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () async {
                  // Persist ratios in profile.goal as simple JSON string or better create fields - for now we'll store as goal text.
                  final prov = context.read<ProfileProvider>();
                  final current = prov.profile;
                  final goalText =
                      'macros:${(protein * 100).round()}-${(carbs * 100).round()}-${(fat * 100).round()}';
                  await prov.updateProfile(current.copyWith(goal: goalText));
                  if (mounted) Navigator.of(context).pop();
                },
                child: Text(
                  'Cập nhật',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _macroRow(
    BuildContext context,
    String name,
    double pct,
    Color color,
    int calories,
    int kcalPerGram,
  ) {
    final theme = Theme.of(context);
    final grams = _grams(pct, calories, kcalPerGram);
    final percentLabel = '${(pct * 100).round()}%';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_iconFor(name), color: color),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '$grams g • $percentLabel',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _roundButton('-', () {
                setState(() {
                  final step = 0.01;
                  final newVal = (pct - step).clamp(0.0, 1.0);
                  if (name == 'Chất đạm') protein = newVal;
                  if (name == 'Đường bột') carbs = newVal;
                  if (name == 'Chất béo') fat = newVal;
                  _normalizeExcept(
                    name == 'Chất đạm'
                        ? 'protein'
                        : name == 'Đường bột'
                        ? 'carbs'
                        : 'fat',
                  );
                });
              }),
              Expanded(
                child: Slider(
                  value: pct.clamp(0.0, 1.0),
                  onChanged: (v) {
                    setState(() {
                      if (name == 'Chất đạm') protein = v;
                      if (name == 'Đường bột') carbs = v;
                      if (name == 'Chất béo') fat = v;
                      _normalizeExcept(
                        name == 'Chất đạm'
                            ? 'protein'
                            : name == 'Đường bột'
                            ? 'carbs'
                            : 'fat',
                      );
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  activeColor: color,
                ),
              ),
              _roundButton('+', () {
                setState(() {
                  final step = 0.01;
                  final newVal = (pct + step).clamp(0.0, 1.0);
                  if (name == 'Chất đạm') protein = newVal;
                  if (name == 'Đường bột') carbs = newVal;
                  if (name == 'Chất béo') fat = newVal;
                  _normalizeExcept(
                    name == 'Chất đạm'
                        ? 'protein'
                        : name == 'Đường bột'
                        ? 'carbs'
                        : 'fat',
                  );
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String name) {
    if (name.contains('đạm')) {
      return Icons.bolt;
    }
    if (name.contains('Đường') || name.toLowerCase().contains('carb')) {
      return Icons.grain;
    }
    return Icons.opacity;
  }

  Widget _roundButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withAlpha((0.12 * 255).round()),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _MacroPainter extends CustomPainter {
  final double p, c, f;
  final ColorScheme colors;
  final double stroke;
  _MacroPainter(this.p, this.c, this.f, this.colors, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    double start = -90.0;
    void drawArc(double pct, Color color) {
      final sweep = 360 * pct;
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - stroke / 2),
        _degToRad(start),
        _degToRad(sweep),
        false,
        paint,
      );
      start += sweep;
    }

    // background ring
    canvas.drawCircle(
      center,
      radius - stroke / 2,
      paint
        ..color = colors.surfaceContainerHighest
        ..strokeWidth = stroke * 1.0,
    );

    drawArc(p, Colors.red);
    drawArc(c, Colors.blue);
    drawArc(f, Colors.amber);
  }

  double _degToRad(double deg) => deg * (3.1415926535897932 / 180);

  @override
  bool shouldRepaint(covariant _MacroPainter old) =>
      old.p != p || old.c != c || old.f != f || old.stroke != stroke;
}
