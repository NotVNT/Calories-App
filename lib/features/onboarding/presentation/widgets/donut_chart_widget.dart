import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutChartWidget extends StatelessWidget {
  final double proteinPercent;
  final double carbPercent;
  final double fatPercent;
  final double size;

  const DonutChartWidget({
    super.key,
    required this.proteinPercent,
    required this.carbPercent,
    required this.fatPercent,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutChartPainter(
          proteinPercent: proteinPercent,
          carbPercent: carbPercent,
          fatPercent: fatPercent,
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double proteinPercent;
  final double carbPercent;
  final double fatPercent;

  _DonutChartPainter({
    required this.proteinPercent,
    required this.carbPercent,
    required this.fatPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6; // Donut hole

    // Colors for each macro
    const proteinColor = Color(0xFF4CAF50); // Green
    const carbColor = Color(0xFF2196F3); // Blue
    const fatColor = Color(0xFFFF9800); // Orange

    // Normalize percentages to 360 degrees
    final total = proteinPercent + carbPercent + fatPercent;
    final proteinAngle = (proteinPercent / total) * 360;
    final carbAngle = (carbPercent / total) * 360;
    final fatAngle = (fatPercent / total) * 360;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    // Draw Protein segment
    if (proteinPercent > 0) {
      final proteinSweepAngle = proteinAngle * (3.14159 / 180);
      _drawArc(
        canvas,
        center,
        radius,
        innerRadius,
        startAngle,
        proteinSweepAngle,
        proteinColor,
      );
      startAngle += proteinSweepAngle;
    }

    // Draw Carb segment
    if (carbPercent > 0) {
      final carbSweepAngle = carbAngle * (3.14159 / 180);
      _drawArc(
        canvas,
        center,
        radius,
        innerRadius,
        startAngle,
        carbSweepAngle,
        carbColor,
      );
      startAngle += carbSweepAngle;
    }

    // Draw Fat segment
    if (fatPercent > 0) {
      final fatSweepAngle = fatAngle * (3.14159 / 180);
      _drawArc(
        canvas,
        center,
        radius,
        innerRadius,
        startAngle,
        fatSweepAngle,
        fatColor,
      );
    }
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Outer arc
    path.addArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      sweepAngle,
    );
    
    // Line to inner arc
    final endAngle = startAngle + sweepAngle;
    final endX = center.dx + innerRadius * math.cos(endAngle);
    final endY = center.dy + innerRadius * math.sin(endAngle);
    path.lineTo(endX, endY);
    
    // Inner arc (reverse direction)
    path.addArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      endAngle,
      -sweepAngle,
    );
    
    // Close path
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.proteinPercent != proteinPercent ||
        oldDelegate.carbPercent != carbPercent ||
        oldDelegate.fatPercent != fatPercent;
  }
}

