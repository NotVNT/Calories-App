import 'package:flutter/material.dart';

class MascotWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const MascotWidget({
    super.key,
    this.size = 200,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final mascotColor = color ?? const Color(0xFF9B59B6); // Purple mascot
    return CustomPaint(
      size: Size(size, size),
      painter: _MascotPainter(mascotColor),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final Color color;

  _MascotPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withAlpha((0.3 * 255).round());

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Body (rounded rectangle)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 20),
        width: size.width * 0.6,
        height: size.height * 0.5,
      ),
      const Radius.circular(30),
    );
    canvas.drawRRect(bodyRect, paint);
    canvas.drawRRect(bodyRect, strokePaint);

    // Head (circle)
    final headRadius = size.width * 0.3;
    canvas.drawCircle(Offset(centerX, centerY - 30), headRadius, paint);
    canvas.drawCircle(
      Offset(centerX, centerY - 30),
      headRadius,
      strokePaint,
    );

    // Ears
    final earPath = Path()
      ..moveTo(centerX - headRadius * 0.6, centerY - 60)
      ..lineTo(centerX - headRadius * 0.3, centerY - 90)
      ..lineTo(centerX - headRadius * 0.9, centerY - 75)
      ..close();
    canvas.drawPath(earPath, paint);
    canvas.drawPath(earPath, strokePaint);

    // Second ear
    final earPath2 = Path()
      ..moveTo(centerX + headRadius * 0.6, centerY - 60)
      ..lineTo(centerX + headRadius * 0.3, centerY - 90)
      ..lineTo(centerX + headRadius * 0.9, centerY - 75)
      ..close();
    canvas.drawPath(earPath2, paint);
    canvas.drawPath(earPath2, strokePaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(centerX - 15, centerY - 40),
      8,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(centerX + 15, centerY - 40),
      8,
      eyePaint,
    );

    final eyeDotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(centerX - 15, centerY - 40),
      4,
      eyeDotPaint,
    );
    canvas.drawCircle(
      Offset(centerX + 15, centerY - 40),
      4,
      eyeDotPaint,
    );

    // Eyebrows
    final eyebrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX - 25, centerY - 55),
      Offset(centerX - 10, centerY - 50),
      eyebrowPaint,
    );
    canvas.drawLine(
      Offset(centerX + 25, centerY - 55),
      Offset(centerX + 10, centerY - 50),
      eyebrowPaint,
    );

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX - 10, centerY - 20),
      Offset(centerX + 10, centerY - 20),
      mouthPaint,
    );

    // Whiskers
    final whiskerPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - 40, centerY - 30),
      Offset(centerX - 25, centerY - 25),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(centerX - 40, centerY - 20),
      Offset(centerX - 25, centerY - 20),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(centerX + 40, centerY - 30),
      Offset(centerX + 25, centerY - 25),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(centerX + 40, centerY - 20),
      Offset(centerX + 25, centerY - 20),
      whiskerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



