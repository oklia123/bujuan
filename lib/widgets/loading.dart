import 'dart:math';

import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final Size? size;

  const LoadingIndicator({super.key, this.size});

  @override
  LoadingIndicatorState createState() => LoadingIndicatorState();
}

class LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: CustomPaint(
        painter: _LoadingPainter(_controller),
        size: widget.size ?? const Size(56, 56),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _LoadingPainter extends CustomPainter {
  final Animation<double> animation;

  _LoadingPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    const double barWidth = 2;
    double barHeight = size.width / 6;
    const int barCount = 11;
    final Paint paint = Paint()..color = Colors.grey;

    for (int i = 0; i < barCount; i++) {
      final double angle = (2 * pi / barCount) * i;

      final int alpha =
          ((1.0 - ((i + animation.value * barCount) % barCount) / barCount) * 255).toInt();
      paint.color = Colors.grey.withAlpha(alpha); // 设置透明度

      canvas.save();

      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(angle);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            -barWidth / 2,
            -radius + barHeight,
            barWidth,
            barHeight,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
