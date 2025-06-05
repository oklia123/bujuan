import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurvedProgressBar extends StatefulWidget {
  final double progress;
  final ValueChanged<double>? onProgressChange;
  final Color? progressColor;
  final Color? activeProgressColor;

  const CurvedProgressBar(
      {super.key,
      required this.progress,
      this.onProgressChange,
      this.progressColor,
      this.activeProgressColor});

  @override
  CurvedProgressBarState createState() => CurvedProgressBarState();
}

class CurvedProgressBarState extends State<CurvedProgressBar> {
  double _progress = 0.0;

  @override
  void initState() {
    _progress = widget.progress;
    super.initState();
  }

  void _updateProgress(Offset localPosition, Size size) {
    final newProgress = (localPosition.dx / size.width).clamp(0.0, 1.0);
    setState(() {
      _progress = newProgress;
    });
    widget.onProgressChange?.call(newProgress);
  }


  @override
  void didUpdateWidget(covariant CurvedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      setState(() {
        _progress = widget.progress.clamp(0.0, 1.0);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        _updateProgress(details.localPosition, box.size);
      },
      onTapDown: (TapDownDetails details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        _updateProgress(details.localPosition, box.size);
      },
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width, 35.h),
        painter: CurvedProgressPainter(
            progress: _progress,
            progressColor: widget.progressColor ?? Colors.grey,
            activeProgressColor: widget.activeProgressColor ?? Colors.red),
      ),
    );
  }
}

class CurvedProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color activeProgressColor;

  CurvedProgressPainter(
      {required this.progress, required this.progressColor, required this.activeProgressColor});

  Path createWavePath(Size size, double endX) {
    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(size.width / 4, -size.height / 3, size.width / 2, size.height / 2);
    path.quadraticBezierTo(
        3 * size.width / 4, size.height + size.height / 3, size.width, size.height / 2);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        [progressColor.withOpacity(.2), progressColor],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height / 2),
        Offset(size.width * progress, size.height / 2),
        [activeProgressColor.withOpacity(.2), activeProgressColor],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    Path fullPath = createWavePath(size, size.width);
    canvas.drawPath(fullPath, backgroundPaint);

    ui.PathMetrics fullMetrics = fullPath.computeMetrics();
    Path progressPath = Path();
    for (ui.PathMetric metric in fullMetrics) {
      progressPath.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
    }
    canvas.drawPath(progressPath, progressPaint);

    Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Paint circleBorderPaint = Paint()
      ..color = activeProgressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    ui.PathMetrics progressMetrics = progressPath.computeMetrics();
    Offset circleCenter = Offset(size.width * progress, size.height / 2);
    for (ui.PathMetric metric in progressMetrics) {
      circleCenter = metric.getTangentForOffset(metric.length)?.position ?? circleCenter;
    }
    canvas.drawCircle(circleCenter, 5, circlePaint);
    canvas.drawCircle(circleCenter, 5, circleBorderPaint);
  }

  @override
  bool shouldRepaint(CurvedProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
