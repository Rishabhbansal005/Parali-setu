import 'package:flutter/material.dart';
import '../theme.dart';

/// Clean custom-painted vector illustrations for ParaliSetu.
/// Created with basic Flutter canvas shapes (circles, rects, paths)
/// without any external or copyrighted assets.

class OnboardingIllustration1 extends StatelessWidget {
  const OnboardingIllustration1({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 280,
      child: CustomPaint(
        painter: _FieldSunPainter(),
      ),
    );
  }
}

class _FieldSunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm morning sun
    final sunPaint = Paint()..color = AppTheme.wheatGold.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.3), 45, sunPaint);
    final innerSun = Paint()..color = AppTheme.wheatGold;
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.3), 25, innerSun);

    // Distant rolling green hills
    final hillPaint1 = Paint()..color = const Color(0xFFC8E6C9);
    final hillPath1 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.45, size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath1, hillPaint1);

    // Foreground rich farm field
    final hillPaint2 = Paint()..color = AppTheme.secondaryGreen;
    final hillPath2 = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width, size.height * 0.78)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath2, hillPaint2);

    // Golden paddy stalks
    final stalkPaint = Paint()
      ..color = AppTheme.wheatGold
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 7; i++) {
      final x = 40.0 + i * 32.0;
      final y = size.height * 0.82;
      canvas.drawLine(Offset(x, y), Offset(x + (i % 2 == 0 ? 6 : -6), y - 38), stalkPaint);
      canvas.drawCircle(Offset(x + (i % 2 == 0 ? 6 : -6), y - 40), 4, Paint()..color = AppTheme.wheatGold);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingIllustration2 extends StatelessWidget {
  const OnboardingIllustration2({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 280,
      child: CustomPaint(
        painter: _LogisticsBundlePainter(),
      ),
    );
  }
}

class _LogisticsBundlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(20, 20, size.width - 40, size.height - 40), const Radius.circular(24)),
      bgPaint,
    );

    // Connecting dotted path
    final dashPaint = Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(60, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.25, size.width - 60, size.height * 0.5);
    canvas.drawPath(path, dashPaint);

    // Machine node (Left)
    _drawNode(canvas, Offset(60, size.height * 0.5), Icons.agriculture, AppTheme.primaryGreen);

    // Truck node (Middle)
    _drawNode(canvas, Offset(size.width * 0.5, size.height * 0.35), Icons.local_shipping, AppTheme.wheatGold);

    // Buyer node (Right)
    _drawNode(canvas, Offset(size.width - 60, size.height * 0.5), Icons.factory, AppTheme.secondaryGreen);
  }

  void _drawNode(Canvas canvas, Offset offset, IconData icon, Color color) {
    final circlePaint = Paint()..color = Colors.white;
    canvas.drawCircle(offset, 28, circlePaint);
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(offset, 28, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 26,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingIllustration3 extends StatelessWidget {
  const OnboardingIllustration3({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 280,
      child: CustomPaint(
        painter: _WeighbridgeEscrowPainter(),
      ),
    );
  }
}

class _WeighbridgeEscrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFFFF8E1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(20, 20, size.width - 40, size.height - 40), const Radius.circular(24)),
      bgPaint,
    );

    // Central Weighbridge Scale + Rupee Coin
    final center = Offset(size.width * 0.5, size.height * 0.48);

    // Escrow Shield background
    final shieldPaint = Paint()..color = AppTheme.primaryGreen;
    canvas.drawCircle(center, 44, shieldPaint);

    final innerCircle = Paint()..color = Colors.white;
    canvas.drawCircle(center, 38, innerCircle);

    final checkPaint = Paint()..color = AppTheme.primaryGreen;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.verified.codePoint),
        style: TextStyle(
          fontSize: 40,
          fontFamily: Icons.verified.fontFamily,
          package: Icons.verified.fontPackage,
          color: checkPaint.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));

    // Platform bar below
    final barPaint = Paint()
      ..color = AppTheme.textDark
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.78), Offset(size.width * 0.75, size.height * 0.78), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
