import 'dart:math';

import 'package:bujuan_music/pages/main/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum PanelState { open, closed }

class SlidingUpPanel extends StatefulWidget {
  final Widget? Function()? panelBuilder;

  final Widget? body;

  final double minHeight;

  final double maxHeight;

  final double? snapPoint;

  /// A border to draw around the sliding panel sheet.
  final Border? border;

  final BorderRadiusGeometry? borderRadius;

  final List<BoxShadow>? boxShadow;

  final Color color;

  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  final bool renderPanelSheet;

  final bool panelSnapping;

  final bool disableDraggableOnScrolling;

  final PanelController? controller;

  final bool backdropEnabled;

  final Color backdropColor;

  final double backdropOpacity;

  final bool backdropTapClosesPanel;

  final void Function(double position)? onPanelSlide;

  final VoidCallback? onPanelOpened;

  final VoidCallback? onPanelClosed;

  final bool parallaxEnabled;

  final double parallaxOffset;

  final bool isDraggable;

  final PanelState defaultPanelState;

  const SlidingUpPanel(
      {super.key,
      this.body,
      this.minHeight = 100.0,
      this.maxHeight = 500.0,
      this.snapPoint,
      this.border,
      this.borderRadius,
      this.boxShadow = const <BoxShadow>[
        BoxShadow(
          blurRadius: 8.0,
          color: Color.fromRGBO(0, 0, 0, 0.12),
        )
      ],
      this.color = Colors.white,
      this.padding,
      this.margin,
      this.renderPanelSheet = true,
      this.panelSnapping = true,
      this.disableDraggableOnScrolling = false,
      this.controller,
      this.backdropEnabled = false,
      this.backdropColor = Colors.black,
      this.backdropOpacity = 0.5,
      this.backdropTapClosesPanel = true,
      this.onPanelSlide,
      this.onPanelOpened,
      this.onPanelClosed,
      this.parallaxEnabled = false,
      this.parallaxOffset = 0.1,
      this.isDraggable = true,
      this.defaultPanelState = PanelState.closed,
      this.panelBuilder})
      : assert(panelBuilder != null),
        assert(0 <= backdropOpacity && backdropOpacity <= 1.0),
        assert(snapPoint == null || 0 < snapPoint && snapPoint < 1.0);

  @override
  SlidingUpPanelState createState() => SlidingUpPanelState();
}

class SlidingUpPanelState extends State<SlidingUpPanel> with SingleTickerProviderStateMixin {
  late AnimationController _ac;

  // late final ScrollController _sc;

  final bool _scrollingEnabled = false;
  final VelocityTracker _vt = VelocityTracker.withKind(PointerDeviceKind.touch);

  bool _isPanelVisible = true;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: widget.defaultPanelState == PanelState.closed
            ? 0.0
            : 1.0 //set the default panel state (i.e. set initial value of _ac)
        )
      ..addListener(() {
        if (widget.onPanelSlide != null) widget.onPanelSlide!(_ac.value);
        if (widget.onPanelOpened != null && _ac.value == 1.0) widget.onPanelOpened!();
        if (widget.onPanelClosed != null && _ac.value == 0.0) widget.onPanelClosed!();
      });

    widget.controller?._addState(this);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // alignment: Alignment.bottomCenter,
      children: <Widget>[
        widget.body != null
            ? AnimatedBuilder(
                animation: _ac,
                builder: (context, child) {
                  return Positioned(
                    top: widget.parallaxEnabled ? _getParallax() : 0.0,
                    child: child ?? SizedBox(),
                  );
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: widget.body,
                ),
              )
            : const SizedBox.shrink(),

        //the actual sliding part
        !_isPanelVisible
            ? Container()
            : Consumer(builder: (context,ref,c){
              return Positioned(
                  bottom: -100 * (1-ref.watch(boxPanelDetailDataProvider)),
                  child: _gestureHandler(
                    child: AnimatedBuilder(
                      animation: _ac,
                      builder: (context, child) {
                        double bottom = MediaQuery.of(context).padding.bottom;
                        if (bottom == 0) bottom = 16.h;
                        return Container(
                          height: _ac.value * (widget.maxHeight - widget.minHeight) + widget.minHeight,
                          width: MediaQuery.of(context).size.width - (1 - _ac.value) * 30.w,
                          margin: EdgeInsets.only(
                              left: (1 - _ac.value) * 15.w,
                              right: (1 - _ac.value) * 15.w,
                              bottom: (1 - _ac.value) * bottom),
                          padding: widget.padding,
                          decoration: widget.renderPanelSheet
                              ? BoxDecoration(
                            border: widget.border,
                            borderRadius: BorderRadius.circular((1 - _ac.value) * 16.w),
                            boxShadow: widget.boxShadow,
                            color: widget.color,
                          )
                              : null,
                          child: child,
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned(
                              top: 0.0,
                              width: MediaQuery.of(context).size.width -
                                  (widget.margin != null ? widget.margin!.horizontal : 0) -
                                  (widget.padding != null ? widget.padding!.horizontal : 0),
                              child: SizedBox(
                                height: widget.maxHeight,
                                child: widget.panelBuilder!(),
                              ))
                        ],
                      ),
                    ),
                  ));
        }),
      ],
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  double _getParallax() {
    return -_ac.value * (widget.maxHeight - widget.minHeight) * widget.parallaxOffset;
  }

  bool _ignoreScrollable = false;
  bool _isHorizontalScrollableWidget = false;
  Axis? _scrollableAxis;

  // returns a gesture detector if panel is used
  // and a listener if panelBuilder is used.
  // this is because the listener is designed only for use with linking the scrolling of
  // panels and using it for panels that don't want to linked scrolling yields odd results
  Widget _gestureHandler({required Widget child}) {
    if (!widget.isDraggable) return child;

    return Listener(
      onPointerDown: (PointerDownEvent e) {
        var rb = context.findRenderObject() as RenderBox;
        var result = BoxHitTestResult();
        rb.hitTest(result, position: e.position);
        if (result.path
            .any((entry) => entry.target.runtimeType == IgnoreDraggableWidgetWidgetRenderBox)) {
          _ignoreScrollable = true;
          widget.controller?._nowTargetForceDraggable = false;
          _isHorizontalScrollableWidget = false;
          return;
        } else {
          widget.controller?._nowTargetForceDraggable = false;
          _isHorizontalScrollableWidget = false;
        }
        _ignoreScrollable = false;
        _vt.addPosition(e.timeStamp, e.position);
      },
      onPointerMove: (PointerMoveEvent e) {
        if (_scrollableAxis == null) {
          if (e.delta.dx.abs() > e.delta.dy.abs()) {
            _scrollableAxis = Axis.horizontal;
          } else {
            _scrollableAxis = Axis.vertical;
          }
        }

        if (_isHorizontalScrollableWidget && _scrollableAxis == Axis.horizontal) {
          return;
        }

        if (_ignoreScrollable) return;
        _vt.addPosition(e.timeStamp, e.position); // add current position for velocity tracking
        _onGestureSlide(e.delta.dy);
      },
      onPointerUp: (PointerUpEvent e) {
        if (_ignoreScrollable) return;
        _scrollableAxis = null;
        _onGestureEnd(_vt.getVelocity());
      },
      child: child,
    );
  }

  // double _scMinffset = 0.0;

  // handles the sliding gesture
  void _onGestureSlide(double dy) {
    // only slide the panel if scrolling is not enabled
    if (widget.controller?._nowTargetForceDraggable == false &&
        widget.disableDraggableOnScrolling) {
      return;
    }
    if ((!_scrollingEnabled) ||
        _panelPosition < 1 ||
        widget.controller?._nowTargetForceDraggable == true) {
      _ac.value -= dy / (widget.maxHeight - widget.minHeight);
    }

    // if the panel is open and the user hasn't scrolled, we need to determine
    // whether to enable scrolling if the user swipes up, or disable closing and
    // begin to close the panel if the user swipes down
    // if (_isPanelOpen && _sc.hasClients && _sc.offset <= _scMinffset) {
    //   setState(() {
    //     if (dy < 0) {
    //       _scrollingEnabled = true;
    //     } else {
    //       _scrollingEnabled = false;
    //     }
    //   });
    // }
  }

  // handles when user stops sliding
  void _onGestureEnd(Velocity v) {
    if (widget.controller?._nowTargetForceDraggable == false &&
        widget.disableDraggableOnScrolling) {
      return;
    }
    double minFlingVelocity = 365.0;
    double kSnap = 8;

    //let the current animation finish before starting a new one
    if (_ac.isAnimating) return;

    // if scrolling is allowed and the panel is open, we don't want to close
    // the panel if they swipe up on the scrollable
    if (_isPanelOpen && _scrollingEnabled) return;

    //check if the velocity is sufficient to constitute fling to end
    double visualVelocity = -v.pixelsPerSecond.dy / (widget.maxHeight - widget.minHeight);

    // get minimum distances to figure out where the panel is at
    double d2Close = _ac.value;
    double d2Open = 1 - _ac.value;
    double d2Snap = ((widget.snapPoint ?? 3) - _ac.value)
        .abs(); // large value if null results in not every being the min
    double minDistance = min(d2Close, min(d2Snap, d2Open));

    // check if velocity is sufficient for a fling
    if (v.pixelsPerSecond.dy.abs() >= minFlingVelocity) {
      // snapPoint exists
      if (widget.panelSnapping && widget.snapPoint != null) {
        if (v.pixelsPerSecond.dy.abs() >= kSnap * minFlingVelocity || minDistance == d2Snap) {
          _ac.fling(velocity: visualVelocity);
        } else {
          _flingPanelToPosition(widget.snapPoint!, visualVelocity);
        }

        // no snap point exists
      } else if (widget.panelSnapping) {
        _ac.fling(velocity: visualVelocity);

        // panel snapping disabled
      } else {
        _ac.animateTo(
          _ac.value + visualVelocity * 0.16,
          duration: Duration(milliseconds: 410),
          curve: Curves.decelerate,
        );
      }

      return;
    }

    // check if the controller is already halfway there
    if (widget.panelSnapping) {
      if (minDistance == d2Close) {
        _close();
      } else if (minDistance == d2Snap) {
        _flingPanelToPosition(widget.snapPoint!, visualVelocity);
      } else {
        _open();
      }
    }
  }

  void _flingPanelToPosition(double targetPos, double velocity) {
    final Simulation simulation = SpringSimulation(
        SpringDescription.withDampingRatio(
          mass: 1.0,
          stiffness: 500.0,
          ratio: 1.0,
        ),
        _ac.value,
        targetPos,
        velocity);

    _ac.animateWith(simulation);
  }

  //---------------------------------
  //PanelController related functions
  //---------------------------------

  //close the panel
  Future<void> _close() {
    return _ac.fling(velocity: -1.0);
  }

  //open the panel
  Future<void> _open() {
    return _ac.fling(velocity: 1.0);
  }

  //hide the panel (completely offscreen)
  Future<void> _hide() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = false;
      });
    });
  }

  //show the panel (in collapsed mode)
  Future<void> _show() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = true;
      });
    });
  }

  //animate the panel position to value - must
  //be between 0.0 and 1.0
  Future<void> _animatePanelToPosition(double value,
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(0.0 <= value && value <= 1.0);
    return _ac.animateTo(value, duration: duration, curve: curve);
  }

  //animate the panel position to the snap point
  //REQUIRES that widget.snapPoint != null
  Future<void> _animatePanelToSnapPoint({Duration? duration, Curve curve = Curves.linear}) {
    assert(widget.snapPoint != null);
    return _ac.animateTo(widget.snapPoint!, duration: duration, curve: curve);
  }

  //set the panel position to value - must
  //be between 0.0 and 1.0
  set _panelPosition(double value) {
    assert(0.0 <= value && value <= 1.0);
    _ac.value = value;
  }

  //get the current panel position
  //returns the % offset from collapsed state
  //as a decimal between 0.0 and 1.0
  double get _panelPosition => _ac.value;

  //returns whether or not
  //the panel is still animating
  bool get _isPanelAnimating => _ac.isAnimating;

  //returns whether or not the
  //panel is open
  bool get _isPanelOpen => _ac.value == 1.0;

  //returns whether or not the
  //panel is closed
  bool get _isPanelClosed => _ac.value == 0.0;

  //returns whether or not the
  //panel is shown/hidden
  bool get _isPanelShown => _isPanelVisible;
}

class PanelController {
  SlidingUpPanelState? _panelState;

  void _addState(SlidingUpPanelState panelState) {
    _panelState = panelState;
  }

  bool _nowTargetForceDraggable = false;

  /// Determine if the panelController is attached to an instance
  /// of the SlidingUpPanel (this property must return true before any other
  /// functions can be used)
  bool get isAttached => _panelState != null;

  /// Closes the sliding panel to its collapsed state (i.e. to the  minHeight)
  Future<void> close() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._close();
  }

  /// Opens the sliding panel fully
  /// (i.e. to the maxHeight)
  Future<void> open() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._open();
  }

  /// Hides the sliding panel (i.e. is invisible)
  Future<void> hide() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._hide();
  }

  /// Shows the sliding panel in its collapsed state
  /// (i.e. "un-hide" the sliding panel)
  Future<void> show() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._show();
  }

  /// Animates the panel position to the value.
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToPosition(double value,
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    return _panelState!._animatePanelToPosition(value, duration: duration, curve: curve);
  }

  /// Animates the panel position to the snap point
  /// Requires that the SlidingUpPanel snapPoint property is not null
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToSnapPoint({Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(_panelState!.widget.snapPoint != null,
        "SlidingUpPanel snapPoint property must not be null");
    return _panelState!._animatePanelToSnapPoint(duration: duration, curve: curve);
  }

  set panelPosition(double value) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    _panelState!._panelPosition = value;
  }

  double get panelPosition {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._panelPosition;
  }

  bool get isPanelAnimating {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelAnimating;
  }

  bool get isPanelOpen {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelOpen;
  }

  bool get isPanelClosed {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelClosed;
  }

  bool get isPanelShown {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelShown;
  }
}

/// if you want to prevent the panel from being dragged using the widget,
/// wrap the widget with this
class IgnoreDraggableWidget extends SingleChildRenderObjectWidget {
  final Widget child;

  const IgnoreDraggableWidget({
    super.key,
    required this.child,
  }) : super(
          child: child,
        );

  @override
  IgnoreDraggableWidgetWidgetRenderBox createRenderObject(
    BuildContext context,
  ) {
    return IgnoreDraggableWidgetWidgetRenderBox();
  }
}

class IgnoreDraggableWidgetWidgetRenderBox extends RenderPointerListener {
  @override
  HitTestBehavior get behavior => HitTestBehavior.opaque;
}
