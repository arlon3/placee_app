import 'package:flutter/material.dart';
import '../models/pin.dart';

class PinWidget extends StatelessWidget {
  final Pin pin;
  final double size;
  final VoidCallback? onTap;

  const PinWidget({
    super.key,
    required this.pin,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: pin.color,
          shape: _getBoxShape(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            pin.emoji,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }

  BoxShape _getBoxShape() {
    switch (pin.shape) {
      case PinShape.circle:
        return BoxShape.circle;
      case PinShape.heart:
      case PinShape.star:
        return BoxShape.rectangle; // カスタムシェイプは CustomPaint で実装
    }
  }
}

// カスタムシェイプ用のウィジェット
class CustomShapePinWidget extends StatelessWidget {
  final Pin pin;
  final double size;
  final VoidCallback? onTap;

  const CustomShapePinWidget({
    super.key,
    required this.pin,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size),
        painter: _PinPainter(
          shape: pin.shape,
          color: pin.color,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              pin.emoji,
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final PinShape shape;
  final Color color;

  _PinPainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    switch (shape) {
      case PinShape.circle:
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.width / 2,
          paint,
        );
        break;
      
      case PinShape.heart:
        _drawHeart(canvas, size, paint, shadowPaint);
        break;
      
      case PinShape.star:
        _drawStar(canvas, size, paint, shadowPaint);
        break;
    }
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint, Paint shadowPaint) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h * 0.35);
    path.cubicTo(w / 2, h * 0.25, w * 0.4, h * 0.15, w * 0.25, h * 0.25);
    path.cubicTo(w * 0.1, h * 0.35, w * 0.1, h * 0.55, w * 0.25, h * 0.7);
    path.lineTo(w / 2, h * 0.9);
    path.lineTo(w * 0.75, h * 0.7);
    path.cubicTo(w * 0.9, h * 0.55, w * 0.9, h * 0.35, w * 0.75, h * 0.25);
    path.cubicTo(w * 0.6, h * 0.15, w / 2, h * 0.25, w / 2, h * 0.35);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Size size, Paint paint, Paint shadowPaint) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final outerRadius = w / 2;
    final innerRadius = w / 4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * 3.14159 / 180;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = cx + radius * (angle.cos());
      final y = cy + radius * (angle.sin());

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on double {
  double cos() => this;
  double sin() => this;
}
