import 'dart:math' show pi;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// This is a simplified, performance-optimized version of ZoomDrawer's core layout.
// Main ideas applied:
// 1. Minimize saveLayer: avoid ClipRRect + dynamic shadows during animation.
// 2. Avoid ImageFiltered (blur) while animating; only apply when fully opened.
// 3. Use RepaintBoundary on menu and main content to reduce raster work.
// 4. Split animations: small AnimatedBuilders that only affect Transform/opacity.
// 5. Use simple Container overlays instead of ColorFiltered where possible.

typedef DrawerStyleBuilder = Widget Function(
    BuildContext context,
    double animationValue,
    double slideWidth,
    Widget menuScreen,
    Widget mainScreen,
    );

class OptimizedZoomDrawer extends StatefulWidget {
  const OptimizedZoomDrawer({super.key,
    required this.menuScreen,
    required this.mainScreen,
    this.slideWidth = 275.0,
    this.borderRadius = 16.0,
    this.angle = -12.0,
    this.mainScreenScale = 0.3,
    this.menuBackgroundColor = Colors.transparent,
    this.mainScreenOverlayColor,
    this.menuScreenOverlayColor,
    this.overlayBlur,
    this.duration = const Duration(milliseconds: 250),
    this.disableDragGesture = false,
    this.mainScreenTapClose = false,
  });

  final Widget menuScreen;
  final Widget mainScreen;
  final double slideWidth;
  final double borderRadius;
  final double angle;
  final double mainScreenScale;
  final Color menuBackgroundColor;
  final Color? mainScreenOverlayColor;
  final Color? menuScreenOverlayColor;
  final double? overlayBlur; // applied only when fully opened
  final Duration duration;
  final bool disableDragGesture;
  final bool mainScreenTapClose;

  @override
  _OptimizedZoomDrawerState createState() => _OptimizedZoomDrawerState();
}

class _OptimizedZoomDrawerState extends State<OptimizedZoomDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener(_statusListener);

  double get _value => _controller.value;
  bool _absorbing = false;

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _absorbing = true);
    } else if (status == AnimationStatus.dismissed) {
      setState(() => _absorbing = false);
    }
  }

  void open() => _controller.forward();
  void close() => _controller.reverse();
  void toggle() {
    if (_controller.isCompleted) close();
    else open();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    // simple: allow drag from left edge
    final edge = 56.0; // touch zone
    if (details.globalPosition.dx < edge || _controller.isCompleted) {
      // allow
    } else {
      // ignore
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final width = MediaQuery.of(context).size.width;
    _controller.value += delta / (width * 0.5);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5) open();
    else close();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Menu - kept simple and wrapped in RepaintBoundary
  Widget get _menu {
    Widget child = RepaintBoundary(child: widget.menuScreen);
    // Apply a simple overlay color changing with animation using Opacity
    if (widget.menuScreenOverlayColor != null) {
      child = Stack(
        children: [
          child,
          IgnorePointer(
            ignoring: true,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Container(
                color: widget.menuScreenOverlayColor!.withOpacity(1 - _value),
              ),
            ),
          ),
        ],
      );
    }
    // limit width to slideWidth
    child = Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: widget.slideWidth, child: child),
    );
    return child;
  }

  // Main - also wrapped into RepaintBoundary and minimal layers
  Widget get _main {
    Widget child = RepaintBoundary(child: widget.mainScreen);

    // Apply rounded corners only when opened - avoid Clip during animation
    if (_value > 0.999 && widget.borderRadius > 0) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: child,
      );
    }

    // Overlay color as a simple Container to avoid ColorFiltered
    if (widget.mainScreenOverlayColor != null) {
      child = Stack(
        children: [
          child,
          IgnorePointer(
            ignoring: true,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Container(
                width: double.infinity,
                height: double.infinity,
                color: widget.mainScreenOverlayColor!.withOpacity(_value),
              ),
            ),
          ),
        ],
      );
    }

    // If fully opened and overlayBlur requested, apply blur once
    if (_value > 0.999 && widget.overlayBlur != null && widget.overlayBlur! > 0) {
      child = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: widget.overlayBlur!, sigmaY: widget.overlayBlur!),
        child: child,
      );
    }

    // Small AnimatedBuilder that only changes transform (cheap)
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = widget.slideWidth * _value;
        final scale = 1.0 - (widget.mainScreenScale * _value);
        final rotation = (widget.angle * pi / 180) * _value;

        return Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..translate(slide)
            ..rotateZ(rotation)
            ..scale(scale, scale),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget layout = Stack(
      children: [
        // menu
        _menu,
        // main with tap close and absorbing layer
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (widget.mainScreenTapClose && _absorbing) close();
          },
          child: _main,
        ),
        // optional absorbing transparent barrier
        if (_absorbing)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );

    if (!widget.disableDragGesture) {
      layout = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: layout,
      );
    }

    return layout;
  }
}

// --- Example usage ---

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OptimizedZoomDrawer(
        slideWidth: 260,
        overlayBlur: 6,
        mainScreenOverlayColor: Colors.black.withOpacity(0.4),
        menuScreen: Container(
          color: Colors.blueGrey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ListTile(title: Text('Home', style: TextStyle(color: Colors.white))),
              ListTile(title: Text('Profile', style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
        mainScreen: Builder(
          builder: (context) => SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text('Optimized Drawer Demo'),
                  leading: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      // find state by context is left as exercise; in real app use controller
                      // cast ancestor
                      final state = context.findAncestorStateOfType<_OptimizedZoomDrawerState>();
                      state?.toggle();
                    },
                  ),
                ),
                const Expanded(child: Center(child: Text('Main content'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
