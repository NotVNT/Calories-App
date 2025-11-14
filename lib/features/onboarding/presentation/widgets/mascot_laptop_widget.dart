import 'package:flutter/material.dart';

class MascotLaptopWidget extends StatelessWidget {
  final double size;

  const MascotLaptopWidget({
    super.key,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MascotLaptopPainter(),
    );
  }
}

class _MascotLaptopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mascotColor = const Color(0xFF9B59B6);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = mascotColor;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw mascot (simplified version)
    final headRadius = size.width * 0.2;
    canvas.drawCircle(Offset(centerX - 20, centerY - 40), headRadius, paint);

    // Ears
    final earPath = Path()
      ..moveTo(centerX - 40, centerY - 70)
      ..lineTo(centerX - 25, centerY - 90)
      ..lineTo(centerX - 55, centerY - 80)
      ..close();
    canvas.drawPath(earPath, paint);

    final earPath2 = Path()
      ..moveTo(centerX, centerY - 70)
      ..lineTo(centerX - 15, centerY - 90)
      ..lineTo(centerX + 15, centerY - 80)
      ..close();
    canvas.drawPath(earPath2, paint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(centerX - 30, centerY - 50), 6, eyePaint);
    canvas.drawCircle(Offset(centerX - 10, centerY - 50), 6, eyePaint);

    final eyeDotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(centerX - 30, centerY - 50), 3, eyeDotPaint);
    canvas.drawCircle(Offset(centerX - 10, centerY - 50), 3, eyeDotPaint);

    // Eyebrows
    final eyebrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - 40, centerY - 60),
      Offset(centerX - 25, centerY - 55),
      eyebrowPaint,
    );
    canvas.drawLine(
      Offset(centerX - 20, centerY - 60),
      Offset(centerX - 5, centerY - 55),
      eyebrowPaint,
    );

    // Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - 20, centerY + 10),
        width: size.width * 0.4,
        height: size.height * 0.3,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, paint);

    // Laptop
    final laptopPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE8D5FF);

    final laptopScreen = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + 30, centerY - 10),
        width: size.width * 0.35,
        height: size.height * 0.25,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(laptopScreen, laptopPaint);

    // Laptop base
    final laptopBase = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + 30, centerY + 25),
        width: size.width * 0.4,
        height: size.height * 0.08,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(laptopBase, laptopPaint);

    // Laptop screen content (paw print)
    final screenPaint = Paint()
      ..color = mascotColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final pawSize = 15.0;
    canvas.drawCircle(
      Offset(centerX + 30, centerY - 10),
      pawSize,
      screenPaint,
    );
    canvas.drawCircle(
      Offset(centerX + 20, centerY - 5),
      pawSize * 0.6,
      screenPaint,
    );
    canvas.drawCircle(
      Offset(centerX + 40, centerY - 5),
      pawSize * 0.6,
      screenPaint,
    );
    canvas.drawCircle(
      Offset(centerX + 25, centerY + 5),
      pawSize * 0.6,
      screenPaint,
    );
    canvas.drawCircle(
      Offset(centerX + 35, centerY + 5),
      pawSize * 0.6,
      screenPaint,
    );

    // Cup in hand
    final cupPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE8D5FF);
    final cupRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - 50, centerY + 5),
        width: 20,
        height: 30,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(cupRect, cupPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


