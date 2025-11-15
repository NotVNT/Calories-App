import 'package:flutter/material.dart';
import 'package:calories_app/core/theme/theme.dart';

/// Speech bubble widget for mascot
class SpeechBubbleWidget extends StatelessWidget {
  final String text;
  final double? width;

  const SpeechBubbleWidget({
    super.key,
    required this.text,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bubbleWidth = width ?? constraints.maxWidth;
        return Container(
          width: bubbleWidth,
          constraints: const BoxConstraints(minHeight: 120),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(bubbleWidth, 120),
                painter: _SpeechBubblePainter(),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.nearBlack,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.charmingGreen.withAlpha((0.3 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final borderRadius = AppTheme.radiusMedium;
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 20),
      Radius.circular(borderRadius),
    );

    // Draw main bubble
    canvas.drawRRect(bubbleRect, paint);
    canvas.drawRRect(bubbleRect, borderPaint);

    // Draw tail (pointing down)
    final path = Path()
      ..moveTo(size.width * 0.5 - 15, size.height - 20)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.5 + 15, size.height - 20)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


