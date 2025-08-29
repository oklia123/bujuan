import 'dart:math';
import 'package:flutter/material.dart';

class WaveformWidget extends StatefulWidget {
  final double progress;          // 0..1
  final double min;               // 建议 0
  final double max;               // 建议 1
  final Color playedColor;
  final Color unplayedColor;
  final Color? thumbColor;
  final ValueChanged<double> onChangeEnd; // 仅松手回调

  const WaveformWidget({
    super.key,
    required this.progress,
    required this.min,
    required this.max,
    required this.playedColor,
    required this.unplayedColor,
    this.thumbColor,
    required this.onChangeEnd,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> {
  late final List<double> _audioSamples;
  bool _isDragging = false;
  double _localProgress = 0; // 拖动时使用

  @override
  void initState() {
    super.initState();
    // 固定波形数据：拖动不随机
    final rnd = Random();
    _audioSamples = List.generate(150, (_) => 0.1 + rnd.nextDouble() * 0.8);
    _localProgress = widget.progress;
  }

  // 外部 progress 变化时（播放器推进），若未拖动就同步进来
  @override
  void didUpdateWidget(covariant WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.progress != widget.progress) {
      setState(() {
        _localProgress = widget.progress;
      });
    }
  }

  double _dxToProgress(double dx, double width) {
    final r = (dx / width).clamp(0.0, 1.0);
    return widget.min + r * (widget.max - widget.min);
  }

  void _startDrag(Offset localPos, double width) {
    setState(() {
      _isDragging = true;
      _localProgress = _dxToProgress(localPos.dx, width);
    });
  }

  void _updateDrag(Offset localPos, double width) {
    setState(() {
      _localProgress = _dxToProgress(localPos.dx, width);
    });
  }

  void _endDrag() {
    final value = _localProgress;
    setState(() => _isDragging = false);
    widget.onChangeEnd(value); // 仅在松手时回调
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // 受控：非拖动时用外部 progress，拖动时用 _localProgress
        final progressForPaint = _isDragging ? _localProgress : widget.progress;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (d) => _startDrag(d.localPosition, width),
          onTapUp: (_) => _endDrag(),
          onPanStart: (d) => _startDrag(d.localPosition, width),
          onPanUpdate: (d) => _updateDrag(d.localPosition, width),
          onPanEnd: (_) => _endDrag(),
          child: CustomPaint(
            size: Size(width, height),
            painter: WaveformPainter(
              progress: progressForPaint,
              playedColor: widget.playedColor,
              unplayedColor: widget.unplayedColor,
              min: widget.min,
              max: widget.max,
              thumbColor: widget.thumbColor,
              audioSamples: _audioSamples,
            ),
          ),
        );
      },
    );
  }
}




class WaveformPainter extends CustomPainter {
  final double progress;
  final Color playedColor;
  final Color unplayedColor;
  final Color? thumbColor;
  final double max;
  final double min;
  final List<double> audioSamples; // 外部传入

  WaveformPainter({
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
    required this.max,
    required this.min,
    required this.audioSamples,
    this.thumbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final int sampleCount = audioSamples.length;

    const double barWidth = 3;
    const double spacing = 4;
    const double totalBarWidth = barWidth + spacing;

    final int maxBars = (width / totalBarWidth).floor();
    final int displaySampleCount = sampleCount.clamp(0, maxBars);

    double clampedProgress = ((progress - min) / (max - min)).clamp(0.0, 1.0);

    for (int i = 0; i < displaySampleCount; i++) {
      final double barHeight = audioSamples[i] * height * 0.8;
      final double left = i * totalBarWidth;
      final double top = (height - barHeight) / 2;

      final Paint paint = Paint()
        ..color = i <= (displaySampleCount * clampedProgress).floor()
            ? playedColor
            : unplayedColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barHeight),
          const Radius.circular(3),
        ),
        paint,
      );
    }

    // thumb indicator
    if (clampedProgress > 0 && clampedProgress < 1) {
      final double progressX = (displaySampleCount * clampedProgress) * totalBarWidth;
      const double progressBarWidth = 4;

      final Paint progressPaint = Paint()
        ..color = thumbColor ?? playedColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(progressX - (progressBarWidth / 2), 0, progressBarWidth, height),
          const Radius.circular(3),
        ),
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.unplayedColor != unplayedColor ||
        oldDelegate.thumbColor != thumbColor;
  }
}

