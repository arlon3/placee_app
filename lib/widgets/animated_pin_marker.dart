import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/pin.dart';
import '../utils/ui_utils.dart';

/// アニメーション付きピンマーカー
/// 
/// 機能:
/// - タップ時のスケールアニメーション
/// - パルスエフェクト（オプション）
/// - ホバー効果
/// - スムーズなトランジション
class AnimatedPinMarker extends StatefulWidget {
  final Pin pin;
  final VoidCallback onTap;
  final bool showPulse;
  final double size;

  const AnimatedPinMarker({
    super.key,
    required this.pin,
    required this.onTap,
    this.showPulse = false,
    this.size = 40,
  });

  @override
  State<AnimatedPinMarker> createState() => _AnimatedPinMarkerState();
}

class _AnimatedPinMarkerState extends State<AnimatedPinMarker>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // スケールアニメーション（タップ時）
    _scaleController = AnimationController(
      vsync: this,
      duration: UIUtils.fastAnimationDuration,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: UIUtils.animationCurve,
    ));
    
    // パルスアニメーション（常時）
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // パルスエフェクト（背景）
          if (widget.showPulse) _buildPulseEffect(),
          
          // ピン本体
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildPinBody(),
          ),
        ],
      ),
    );
  }

  /// タップダウン処理
  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  /// タップアップ処理
  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  /// タップキャンセル処理
  void _handleTapCancel() {
    _scaleController.reverse();
  }

  /// パルスエフェクト
  Widget _buildPulseEffect() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: widget.size * 1.2,
        height: widget.size * 1.2,
        decoration: BoxDecoration(
          color: _getPinColor().withOpacity(0.3),
          shape: _getPinShape() == PinShape.circle
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: _getPinShape() == PinShape.square
              ? BorderRadius.circular(widget.size * 0.2)
              : null,
        ),
      ),
    );
  }

  /// ピン本体
  Widget _buildPinBody() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: _getPinColor(),
        shape: _getPinShape() == PinShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: _getPinShape() == PinShape.square
            ? BorderRadius.circular(widget.size * 0.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.pin.emoji,
          style: TextStyle(fontSize: widget.size * 0.5),
        ),
      ),
    );
  }

  /// ピンの色を取得
  Color _getPinColor() {
    return UIUtils.getCategoryColor(
      widget.pin.category.toString().split('.').last,
    );
  }

  /// ピンの形状を取得
  PinShape _getPinShape() {
    return widget.pin.postType == PostType.visited
        ? PinShape.circle
        : PinShape.square;
  }
}

/// クラスター化されたピンマーカー
/// 
/// 複数のピンが近接している場合に使用
class ClusteredPinMarker extends StatefulWidget {
  final List<Pin> pins;
  final VoidCallback onTap;
  final double size;

  const ClusteredPinMarker({
    super.key,
    required this.pins,
    required this.onTap,
    this.size = 50,
  });

  @override
  State<ClusteredPinMarker> createState() => _ClusteredPinMarkerState();
}

class _ClusteredPinMarkerState extends State<ClusteredPinMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      vsync: this,
      duration: UIUtils.fastAnimationDuration,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: UIUtils.animationCurve,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: UIUtils.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.pins.length}',
              style: TextStyle(
                fontSize: widget.size * 0.4,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// カスタムピンマーカー（Google Maps風）
/// 
/// 涙滴型のピンデザイン
class TearDropPinMarker extends StatefulWidget {
  final Pin pin;
  final VoidCallback onTap;
  final double size;

  const TearDropPinMarker({
    super.key,
    required this.pin,
    required this.onTap,
    this.size = 48,
  });

  @override
  State<TearDropPinMarker> createState() => _TearDropPinMarkerState();
}

class _TearDropPinMarkerState extends State<TearDropPinMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    // 初期表示時にバウンス
    Future.delayed(Duration.zero, () {
      _bounceController.forward();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _bounceController.forward(from: 0.5);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: CustomPaint(
          size: Size(widget.size, widget.size * 1.4),
          painter: TearDropPainter(
            color: _getPinColor(),
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size * 1.4,
            child: Align(
              alignment: Alignment(0, -0.3),
              child: Text(
                widget.pin.emoji,
                style: TextStyle(fontSize: widget.size * 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPinColor() {
    return UIUtils.getCategoryColor(
      widget.pin.category.toString().split('.').last,
    );
  }
}

/// 涙滴型ピンのカスタムペインター
class TearDropPainter extends CustomPainter {
  final Color color;

  TearDropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    
    // 涙滴型のパス
    final center = Offset(size.width / 2, size.height * 0.35);
    final radius = size.width * 0.35;
    
    // 上部の円
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    
    // 下部の三角形（涙滴の先端）
    path.moveTo(center.dx - radius * 0.3, center.dy + radius * 0.7);
    path.lineTo(center.dx, size.height * 0.95);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.7);
    path.close();

    // 影を描画
    canvas.save();
    canvas.translate(0, 2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // ピン本体を描画
    canvas.drawPath(path, paint);
    
    // ハイライト（光沢）
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path();
    highlightPath.addOval(
      Rect.fromCircle(
        center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
        radius: radius * 0.25,
      ),
    );
    
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(TearDropPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// ピンマーカーのファクトリー
class PinMarkerFactory {
  /// スタイルに応じたピンマーカーを作成
  static Widget create({
    required Pin pin,
    required VoidCallback onTap,
    PinMarkerStyle style = PinMarkerStyle.standard,
    bool showPulse = false,
    double size = 40,
  }) {
    switch (style) {
      case PinMarkerStyle.standard:
        return AnimatedPinMarker(
          pin: pin,
          onTap: onTap,
          showPulse: showPulse,
          size: size,
        );
      case PinMarkerStyle.tearDrop:
        return TearDropPinMarker(
          pin: pin,
          onTap: onTap,
          size: size,
        );
    }
  }
}

/// ピンマーカーのスタイル
enum PinMarkerStyle {
  standard,  // 標準（丸・四角）
  tearDrop,  // 涙滴型（Google Maps風）
}
