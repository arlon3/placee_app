import 'package:flutter/material.dart';

import '../models/pin.dart';

class PinWidget extends StatelessWidget {
  final Pin pin;
  final double size;
  final VoidCallback? onTap;

  const PinWidget({
    super.key,
    required this.pin,
    this.size = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size * 1.2),
        painter: _MapPinPainter(
          color: pin.color,
          emoji: pin.emoji,
        ),
      ),
    );
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
    this.size = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size * 1.2),
        painter: _MapPinPainter(
          color: pin.color,
          emoji: pin.emoji,
        ),
      ),
    );
  }
}

class _MapPinPainter extends CustomPainter {
  final Color color;
  final String emoji;

  _MapPinPainter({required this.color, required this.emoji});

  @override
  void paint(Canvas canvas, Size size) {
    final pinWidth = size.width;
    final pinHeight = size.height;

    // グラデーションの作成（画像のような赤→ピンク→紫のグラデーション）
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.9),
        color,
        color.withOpacity(0.7),
      ],
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, pinWidth, pinHeight * 0.7),
      )
      ..style = PaintingStyle.fill;

    // 影の描画
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // マップピンの形を描画
    final path = Path();

    // 上部の円形部分
    final circleRadius = pinWidth * 0.4;
    final circleCenter = Offset(pinWidth / 2, circleRadius + 2);

    // 円を描画
    path.addOval(Rect.fromCircle(center: circleCenter, radius: circleRadius));

    // 下部の尖った部分
    final tipY = pinHeight * 0.85;
    final tipPoint = Offset(pinWidth / 2, tipY);

    // 円の下部から尖った先端への線
    final leftPoint = Offset(pinWidth / 2 - circleRadius * 0.5,
        circleCenter.dy + circleRadius * 0.7);
    final rightPoint = Offset(pinWidth / 2 + circleRadius * 0.5,
        circleCenter.dy + circleRadius * 0.7);

    path.moveTo(leftPoint.dx, leftPoint.dy);
    path.quadraticBezierTo(
      pinWidth / 2 - circleRadius * 0.3,
      tipY - circleRadius * 0.5,
      tipPoint.dx,
      tipPoint.dy,
    );
    path.quadraticBezierTo(
      pinWidth / 2 + circleRadius * 0.3,
      tipY - circleRadius * 0.5,
      rightPoint.dx,
      rightPoint.dy,
    );

    // 影を描画
    canvas.drawPath(path.shift(const Offset(2, 3)), shadowPaint);

    // 本体を描画
    canvas.drawPath(path, gradientPaint);

    // ハイライトを追加（つやっと感）
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.addOval(
      Rect.fromCircle(
        center: Offset(
          circleCenter.dx - circleRadius * 0.25,
          circleCenter.dy - circleRadius * 0.25,
        ),
        radius: circleRadius * 0.35,
      ),
    );
    canvas.drawPath(highlightPath, highlightPaint);

    // 白い縁取りを追加
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final borderPath = Path();
    borderPath.addOval(
      Rect.fromCircle(
        center: circleCenter,
        radius: circleRadius - 1,
      ),
    );
    canvas.drawPath(borderPath, borderPaint);

    // 絵文字（ハンバーガーアイコン）を描画
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: circleRadius * 0.9,
          fontFamily: 'NotoColorEmoji',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - textPainter.width / 2,
        circleCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
