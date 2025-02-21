import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SlideDirection {
  up,
  down,
}

enum PanelState {
  open,
  close,
}

class SlidingUpPanel extends StatefulWidget {
  /// If non-null, this can be used to control the state of the panel.
  final PanelController? controller;

  /// The Widget that slides into view. When the
  /// panel is collapsed and if [collapsed] is null,
  /// then top portion of this Widget will be displayed;
  /// otherwise, [collapsed] will be displayed overtop
  /// of this Widget. If [panel] and [panelBuilder] are both non-null,
  /// [panel] will be used.
  final Widget? panel;

  /// WARNING: This feature is still in beta and is subject to change without
  /// notice. Stability is not guaranteed. Provides a [ScrollController] and
  /// [ScrollPhysics] to attach to a scrollable object in the panel that links
  /// the panel position with the scroll position. Useful for implementing an
  /// infinite scroll behavior. If [panel] and [panelBuilder] are both non-null,
  /// [panel] will be used.
  final Widget Function(ScrollController sc)? panelBuilder;

  /// The Widget displayed overtop the [panel] when collapsed.
  /// This fades out as the panel is opened.
  final Widget? collapsed;

  /// Optional persistent widget that floats above the [panel] and attaches
  /// to the top of the [panel]. Content at the top of the panel will be covered
  /// by this widget. Add padding to the bottom of the `panel` to
  /// avoid coverage.
  final Widget? header;

  /// Optional persistent widget that floats above the [panel] and
  /// attaches to the bottom of the [panel]. Content at the bottom of the panel
  /// will be covered by this widget. Add padding to the bottom of the `panel`
  /// to avoid coverage.
  final Widget? footer;

  /// The Widget that lies underneath the sliding panel.
  /// This Widget automatically sizes itself
  /// to fill the screen.
  final Widget? body;

  /// Contains various parameters
  final SlidingUpPanelOptions options;

  /// If non-null, this callback
  /// is called as the panel slides around with the
  /// current position of the panel. The position is a double
  /// between 0.0 and 1.0 where 0.0 is fully collapsed and 1.0 is fully open.
  final void Function(double position)? onPanelSlide;

  /// If non-null, this callback is called when the
  /// panel is fully opened
  final VoidCallback? onPanelOpened;

  /// If non-null, this callback is called when the panel
  /// is fully collapsed.
  final VoidCallback? onPanelClosed;

  /// If non-null, this callback is called when the panel's
  /// [_maxHeight] value changes.
  final void Function(double position)? onPanelMaxHeightUpdated;

  /// If non-null, this callback is called when the controller
  /// receives the state of the panel.
  final VoidCallback? onAttached;

  const SlidingUpPanel({
    super.key,
    this.controller,
    this.panel,
    this.panelBuilder,
    this.collapsed,
    this.header,
    this.footer,
    this.body,
    this.options = const SlidingUpPanelOptions(),
    this.onPanelSlide,
    this.onPanelOpened,
    this.onPanelClosed,
    this.onPanelMaxHeightUpdated,
    this.onAttached,
  }) : assert(panel != null || panelBuilder != null);

  @override
  State<SlidingUpPanel> createState() => _SlidingUpPanelState();
}

class _SlidingUpPanelState extends State<SlidingUpPanel> with TickerProviderStateMixin {
  late final AnimationController _ac;
  late final ScrollController _sc;

  bool _scrollingEnabled = false;
  final VelocityTracker _vt = VelocityTracker.withKind(PointerDeviceKind.touch);

  final _sliderKey = GlobalKey();
  bool _isPanelVisible = true;

  @override
  void initState() {
    super.initState();
    _maxHeight = widget.options.initialMaxHeight;
    _ac = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: widget.options.defaultPanelState == PanelState.close
            ? 0.0
            : 1.0 // set the default panel state (i.e. set initial value of _ac)
        )
      ..addListener(() {
        if (widget.onPanelSlide != null) widget.onPanelSlide!(_ac.value);

        /// trigger a rebuild whenever the panel is opened/closed, so that
        /// any children that depend on [_isPanelOpen] or [_isPanelClosed]
        /// get rebuilt as well
        if (_ac.value == 0.0 || _ac.value == 1.0) {
          setState(() {});
        }

        if (widget.onPanelOpened != null && _ac.value == 1.0) {
          widget.onPanelOpened!();
        }

        if (widget.onPanelClosed != null && _ac.value == 0.0) {
          widget.onPanelClosed!();
        }

        // notify listeners when the panel is sliding
        widget.controller?._notifyListeners();
      });

    // prevent the panel content from being scrolled only if the widget is
    // draggable and panel scrolling is enabled
    _sc = ScrollController();
    _sc.addListener(() {
      if (widget.options.isDraggable && !_scrollingEnabled) _sc.jumpTo(0);
    });

    widget.controller?._addState(this, widget.onAttached);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: widget.options.slideDirection == SlideDirection.up
              ? Alignment.bottomCenter
              : Alignment.topCenter,
          children: <Widget>[
            // make the back widget take up the entire back side
            widget.body != null
                ? AnimatedBuilder(
                    animation: _ac,
                    builder: (context, child) {
                      return Positioned(
                        top: widget.options.parallaxEnabled ? _getParallax() : 0.0,
                        child: child ?? SizedBox(),
                      );
                    },
                    child: SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                      child: widget.body,
                    ),
                  )
                : Container(),

            // the backdrop to overlay on the body
            !widget.options.backdropEnabled
                ? Container()
                : GestureDetector(
                    onVerticalDragEnd: widget.options.backdropTapClosesPanel
                        ? (details) {
                            // only trigger a close if the drag is towards panel close position
                            if ((widget.options.slideDirection == SlideDirection.up ? 1 : -1) *
                                    details.velocity.pixelsPerSecond.dy >
                                0) {
                              _close();
                            }
                          }
                        : null,
                    onTap: widget.options.backdropTapClosesPanel ? () => _close() : null,
                    child: AnimatedBuilder(
                      animation: _ac,
                      builder: (context, _) {
                        return Container(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          // set color to null so that touch events pass through
                          // to the body when the panel is closed, otherwise,
                          // if a color exists, then touch events won't go through
                          color: _ac.value == 0.0
                              ? null
                              : widget.options.backdropColor
                                  .withOpacity(widget.options.backdropOpacity * _ac.value),
                        );
                      },
                    ),
                  ),

            // the actual sliding part
            !_isPanelVisible
                ? Container()
                : _gestureHandler(
                    child: StatefulBuilder(
                      key: _sliderKey,
                      builder: (context, state) {
                        return AnimatedBuilder(
                          animation: _ac,
                          builder: (context, child) {
                            return Container(
                              height: _ac.value * (_maxHeight - widget.options.initialMinHeight) +
                                  widget.options.initialMinHeight,
                              margin: EdgeInsets.only(
                                  left: (1 - _ac.value) * 10.w,
                                  right: (1 - _ac.value) * 10.w,
                                  bottom: (1 - _ac.value) * MediaQuery.of(context).padding.bottom),
                              padding: widget.options.padding,
                              decoration: widget.options.renderPanelSheet
                                  ? BoxDecoration(
                                      border: widget.options.border,
                                      borderRadius: BorderRadius.circular(10.w*(1 - _ac.value)),
                                      boxShadow: widget.options.boxShadow,
                                      color: widget.options.color,
                                    )
                                  : null,
                              child: child,
                            );
                          },
                          child: Stack(
                            children: <Widget>[
                              // open panel
                              Positioned(
                                top:
                                    widget.options.slideDirection == SlideDirection.up ? 0.0 : null,
                                bottom: widget.options.slideDirection == SlideDirection.down
                                    ? 0.0
                                    : null,
                                width: constraints.maxWidth,
                                child: SizedBox(
                                  height: _maxHeight,
                                  child: widget.panel ?? widget.panelBuilder!(_sc),
                                ),
                              ),

                              // header
                              widget.header != null
                                  ? Positioned(
                                      top: widget.options.slideDirection == SlideDirection.up
                                          ? 0.0
                                          : null,
                                      bottom: widget.options.slideDirection == SlideDirection.down
                                          ? 0.0
                                          : null,
                                      child: widget.header ?? SizedBox(),
                                    )
                                  : Container(),

                              // footer
                              widget.footer != null
                                  ? Positioned(
                                      top: widget.options.slideDirection == SlideDirection.up
                                          ? null
                                          : 0.0,
                                      bottom: widget.options.slideDirection == SlideDirection.down
                                          ? null
                                          : 0.0,
                                      child: widget.footer ?? SizedBox())
                                  : Container(),

                              // collapsed panel
                              Positioned(
                                top:
                                    widget.options.slideDirection == SlideDirection.up ? 0.0 : null,
                                bottom: widget.options.slideDirection == SlideDirection.down
                                    ? 0.0
                                    : null,
                                width: constraints.maxWidth -
                                    (widget.options.margin != null
                                        ? widget.options.margin!.horizontal
                                        : 0) -
                                    (widget.options.padding != null
                                        ? widget.options.padding!.horizontal
                                        : 0),
                                child: SizedBox(
                                  height: widget.options.initialMinHeight,
                                  child: widget.collapsed == null
                                      ? Container()
                                      : FadeTransition(
                                          opacity: Tween(begin: 1.0, end: 0.0).animate(_ac),

                                          // if the panel is open ignore pointers (touch events) on the collapsed
                                          // child so that way touch events go through to whatever is underneath
                                          child: IgnorePointer(
                                            ignoring: _isPanelOpen,
                                            child: widget.collapsed,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        );
      },
    );
  }

  double _getParallax() {
    if (widget.options.slideDirection == SlideDirection.up) {
      return -_ac.value *
          (_maxHeight - widget.options.initialMinHeight) *
          widget.options.parallaxOffset;
    } else {
      return _ac.value *
          (_maxHeight - widget.options.initialMinHeight) *
          widget.options.parallaxOffset;
    }
  }

  // returns a gesture detector if panel is used
  // and a listener if panelBuilder is used.
  // this is because the listener is designed only for use with linking the scrolling of
  // panels and using it for panels that don't want to linked scrolling yields odd results
  Widget _gestureHandler({required Widget child}) {
    if (!widget.options.isDraggable) return child;

    if (widget.panel != null) {
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          _onGestureSlide(details.delta.dy);
        },
        onVerticalDragEnd: (details) {
          _onGestureEnd(details.velocity);
        },
        child: child,
      );
    }

    return Listener(
      onPointerDown: (event) {
        _vt.addPosition(event.timeStamp, event.position);
      },
      onPointerMove: (event) {
        _vt.addPosition(
            event.timeStamp, event.position); // add current position for velocity tracking
        _onGestureSlide(event.delta.dy);
      },
      onPointerUp: (event) {
        _onGestureEnd(_vt.getVelocity());
      },
      child: child,
    );
  }

  // handles the sliding gesture
  void _onGestureSlide(double dy) {
    // prevent from accessing AnimationController methods after calling dispose on it
    if (!mounted) return;

    // only slide the panel if scrolling is not enabled
    if (!_scrollingEnabled) {
      if (widget.options.slideDirection == SlideDirection.up) {
        _ac.value -= dy / (_maxHeight - widget.options.initialMinHeight);
      } else {
        _ac.value += dy / (_maxHeight - widget.options.initialMinHeight);
      }
    }

    // if the panel is open and the user hasn't scrolled, we need to determine
    // whether to enable scrolling if the user swipes up, or disable closing and
    // begin to close the panel if the user swipes down
    if (_isPanelOpen && _sc.hasClients && _sc.offset <= 0) {
      setState(() {
        if (dy < 0) {
          _scrollingEnabled = true;
        } else {
          _scrollingEnabled = false;
        }
      });
    }
  }

  // handles when user stops sliding
  void _onGestureEnd(Velocity v) {
    // prevent from accessing AnimationController methods after calling dispose on it
    if (!mounted) return;

    double minFlingVelocity = 365.0;
    double kSnap = 8;

    // let the current animation finish before starting a new one
    if (_ac.isAnimating) return;

    // if scrolling is allowed and the panel is open, we don't want to close
    // the panel if they swipe up on the scrollable
    if (_isPanelOpen && _scrollingEnabled) return;

    // check if the velocity is sufficient to constitute fling to end
    double visualVelocity = -v.pixelsPerSecond.dy / (_maxHeight - widget.options.initialMinHeight);

    // reverse visual velocity to account for slide direction
    if (widget.options.slideDirection == SlideDirection.down) {
      visualVelocity = -visualVelocity;
    }

    // get minimum distances to figure out where the panel is at
    double d2Close = _ac.value;
    double d2Open = 1 - _ac.value;
    double d2Snap = ((widget.options.snapPoint ?? 3) - _ac.value)
        .abs(); // large value if null results in not every being the min
    double minDistance = min(d2Close, min(d2Snap, d2Open));

    // check if velocity is sufficient for a fling
    if (v.pixelsPerSecond.dy.abs() >= minFlingVelocity) {
      // snapPoint exists
      if (widget.options.panelSnapping && widget.options.snapPoint != null) {
        if (v.pixelsPerSecond.dy.abs() >= kSnap * minFlingVelocity || minDistance == d2Snap) {
          _ac.fling(velocity: visualVelocity);
        } else {
          // if position is closest to close position
          // and velocity is going in the close direction
          if (visualVelocity < 0 && minDistance == d2Close) {
            _close();
          } else {
            // go to snap position
            _flingPanelToPosition(widget.options.snapPoint!, visualVelocity);
          }
        }

        // no snap point exists
      } else if (widget.options.panelSnapping) {
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
    if (widget.options.panelSnapping) {
      if (minDistance == d2Close) {
        _close();
      } else if (minDistance == d2Snap) {
        _flingPanelToPosition(widget.options.snapPoint!, visualVelocity);
      } else {
        _open();
      }
    }
  }

  void _flingPanelToPosition(double targetPos, double velocity) {
    final simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: 500.0,
        ratio: 1.0,
      ),
      _ac.value,
      targetPos,
      velocity,
    );

    _ac.animateWith(simulation);
  }

  // ---------------------------------
  // PanelController related functions
  // ---------------------------------

  // close the panel
  Future<void> _close() {
    return _ac.fling(velocity: -1.0);
  }

  // open the panel
  Future<void> _open() {
    return _ac.fling(velocity: 1.0);
  }

  // hide the panel (completely offscreen)
  Future<void> _hide() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = false;
      });
    });
  }

  // show the panel (in collapsed mode)
  Future<void> _show() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = true;
      });
    });
  }

  // animate the panel position to value -
  // must be between 0.0 and 1.0
  Future<void> _animatePanelToPosition(double value,
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(0.0 <= value && value <= 1.0);
    return _ac.animateTo(value, duration: duration, curve: curve);
  }

  // animate the panel position to the snap point
  // REQUIRES that widget.snapPoint != null
  Future<void> _animatePanelToSnapPoint({Duration? duration, Curve curve = Curves.linear}) {
    assert(widget.options.snapPoint != null);
    return _ac.animateTo(widget.options.snapPoint!, duration: duration, curve: curve);
  }

  // animate the panel position to the new maxHeight value -
  // must be greater then [initialMinHeight]
  void _animatePanelToMaxHeight(double maxHeight,
      {required Duration duration, Curve curve = Curves.linear}) {
    assert(widget.options.initialMinHeight <= maxHeight);
    final controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    final animation = CurveTween(curve: curve).animate(controller);
    animation.addListener(() {
      setState(() {
        _maxHeight = animation.drive(Tween<double>(begin: _maxHeight, end: maxHeight)).value;
      });

      if (widget.onPanelMaxHeightUpdated != null && !_isPanelClosed) {
        widget.onPanelMaxHeightUpdated!(_maxHeight);
      }
      widget.controller?._notifyListeners();
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  // set the panel position to value - must
  // be between 0.0 and 1.0
  set _position(double value) {
    assert(0.0 <= value && value <= 1.0);
    _ac.value = value;
  }

  // get the current panel position
  // returns the % offset from collapsed state
  // as a decimal between 0.0 and 1.0
  double get _position => _ac.value;

  // get the current panel max height
  double _maxHeight = 0.0;

  // returns whether or not
  // the panel is still animating
  bool get _isPanelAnimating => _ac.isAnimating;

  // returns whether or not the
  // panel is open
  bool get _isPanelOpen => _ac.value >= 0.99;

  // returns whether or not the
  // panel is closed
  bool get _isPanelClosed => _ac.value <= 0.01;

  // returns whether or not the
  // panel is shown/hidden
  bool get _isPanelShown => _isPanelVisible;
}

class PanelController with ChangeNotifier {
  _SlidingUpPanelState? _panelState;

  void _addState(_SlidingUpPanelState panelState, VoidCallback? onAttached) {
    _panelState = panelState;
    if (onAttached != null) {
      onAttached();
    }
  }

  void _notifyListeners() {
    notifyListeners();
  }

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
  Future<void> open({double? maxHeight}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    final defaultHeight = _panelState!.widget.options.initialMaxHeight;
    bool hasChanges = false;

    if (maxHeight == null && defaultHeight != _panelState!._maxHeight) {
      _panelState!._maxHeight = defaultHeight;
      hasChanges = true;
    } else if (maxHeight != null && maxHeight != _panelState!._maxHeight) {
      _panelState!._maxHeight = maxHeight;
      hasChanges = true;
    }

    if (hasChanges) {
      _panelState!._sliderKey.currentState?.setState(() {});
    }

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

  /// Animates the panel position to the new maxHeight value.
  /// The value must be greater then [initialMinHeight].
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  void animatePanelToMaxHeight(double maxHeight,
      {Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(_panelState!.widget.options.initialMinHeight <= maxHeight);

    final defaultHeight = _panelState!.widget.options.initialMaxHeight;
    bool hasChanges = false;

    if (defaultHeight != _panelState!._maxHeight) {
      hasChanges = true;
    } else if (maxHeight != _panelState!._maxHeight) {
      hasChanges = true;
    }

    if (hasChanges) {
      _panelState!._animatePanelToMaxHeight(maxHeight, duration: duration, curve: curve);
    }
  }

  /// Animates the panel position to the snap point
  /// Requires that the SlidingUpPanel snapPoint property is not null
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToSnapPoint({Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(_panelState!.widget.options.snapPoint != null,
        "SlidingUpPanel snapPoint property must not be null");
    return _panelState!._animatePanelToSnapPoint(duration: duration, curve: curve);
  }

  /// Sets the panel position (without animation).
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  set position(double value) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    _panelState!._position = value;
  }

  /// Gets the current panel position.
  /// Returns the % offset from collapsed state
  /// to the open state
  /// as a decimal between 0.0 and 1.0
  /// where 0.0 is fully collapsed and
  /// 1.0 is full open.
  double get position {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._position;
  }

  /// Gets the current panel position in pixels.
  double get positionInPixels {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._position *
            (_panelState!._maxHeight - _panelState!.widget.options.initialMinHeight) +
        _panelState!.widget.options.initialMinHeight;
  }

  /// Sets the panel max height (without animation).
  set maxHeight(double value) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value);
    _panelState!._maxHeight = value;
    _panelState!._sliderKey.currentState?.setState(() {});
  }

  /// Gets the current panel max height.
  double get maxHeight {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._maxHeight;
  }

  /// Returns whether or not the panel is
  /// currently animating.
  bool get isPanelAnimating {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelAnimating;
  }

  /// Returns whether or not the
  /// panel is open.
  bool get isPanelOpen {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelOpen;
  }

  /// Returns whether or not the
  /// panel is closed.
  bool get isPanelClosed {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelClosed;
  }

  /// Returns whether or not the
  /// panel is shown/hidden.
  bool get isPanelShown {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelShown;
  }
}

class SlidingUpPanelOptions {
  /// The height of the sliding panel when fully collapsed.
  final double initialMinHeight;

  /// The height of the sliding panel when fully open.
  final double initialMaxHeight;

  /// A point between [initialMinHeight] and [initialMaxHeight] that the panel snaps to
  /// while animating. A fast swipe on the panel will disregard this point
  /// and go directly to the open/close position. This value is represented as a
  /// percentage of the total animation distance ([initialMaxHeight] - [initialMinHeight]),
  /// so it must be between 0.0 and 1.0, exclusive.
  final double? snapPoint;

  /// A border to draw around the sliding panel sheet.
  final Border? border;

  /// If non-null, the corners of the sliding panel sheet are rounded by this [BorderRadiusGeometry].
  final BorderRadiusGeometry? borderRadius;

  /// A list of shadows cast behind the sliding panel sheet.
  final List<BoxShadow>? boxShadow;

  /// The color to fill the background of the sliding panel sheet.
  final Color color;

  /// The amount to inset the children of the sliding panel sheet.
  final EdgeInsetsGeometry? padding;

  /// Empty space surrounding the sliding panel sheet.
  final EdgeInsetsGeometry? margin;

  /// Set to false to not to render the sheet the [panel] sits upon.
  /// This means that only the [body], [collapsed], and the [panel]
  /// Widgets will be rendered.
  /// Set this to false if you want to achieve a floating effect or
  /// want more customization over how the sliding panel
  /// looks like.
  final bool renderPanelSheet;

  /// Set to false to disable the panel from snapping open or closed.
  final bool panelSnapping;

  /// If non-null, shows a darkening shadow over the [body] as the panel slides open.
  final bool backdropEnabled;

  /// Shows a darkening shadow of this [Color] over the [body] as the panel slides open.
  final Color backdropColor;

  /// The opacity of the backdrop when the panel is fully open.
  /// This value can range from 0.0 to 1.0 where 0.0 is completely transparent
  /// and 1.0 is completely opaque.
  final double backdropOpacity;

  /// Flag that indicates whether or not tapping the
  /// backdrop closes the panel. Defaults to true.
  final bool backdropTapClosesPanel;

  /// If non-null and true, the SlidingUpPanel exhibits a
  /// parallax effect as the panel slides up. Essentially,
  /// the body slides up as the panel slides up.
  final bool parallaxEnabled;

  /// Allows for specifying the extent of the parallax effect in terms
  /// of the percentage the panel has slid up/down. Recommended values are
  /// within 0.0 and 1.0 where 0.0 is no parallax and 1.0 mimics a
  /// one-to-one scrolling effect. Defaults to a 10% parallax.
  final double parallaxOffset;

  /// Allows toggling of the draggability of the SlidingUpPanel.
  /// Set this to false to prevent the user from being able to drag
  /// the panel up and down. Defaults to true.
  final bool isDraggable;

  /// Either SlideDirection.UP or SlideDirection.DOWN. Indicates which way
  /// the panel should slide. Defaults to UP. If set to DOWN, the panel attaches
  /// itself to the top of the screen and is fully opened when the user swipes
  /// down on the panel.
  final SlideDirection slideDirection;

  /// The default state of the panel; either PanelState.OPEN or PanelState.CLOSED.
  /// This value defaults to PanelState.CLOSED which indicates that the panel is
  /// in the closed position and must be opened. PanelState.OPEN indicates that
  /// by default the Panel is open and must be swiped closed by the user.
  final PanelState defaultPanelState;

  const SlidingUpPanelOptions({
    this.initialMinHeight = 100.0,
    this.initialMaxHeight = 400.0,
    this.snapPoint,
    this.border,
    this.borderRadius,
    this.boxShadow = const <BoxShadow>[
      BoxShadow(
        blurRadius: 8.0,
        color: Color.fromRGBO(0, 0, 0, 0.25),
      )
    ],
    this.color = Colors.white,
    this.padding,
    this.margin,
    this.renderPanelSheet = true,
    this.panelSnapping = true,
    this.backdropEnabled = false,
    this.backdropColor = Colors.black,
    this.backdropOpacity = 0.5,
    this.backdropTapClosesPanel = true,
    this.parallaxEnabled = false,
    this.parallaxOffset = 0.1,
    this.isDraggable = true,
    this.slideDirection = SlideDirection.up,
    this.defaultPanelState = PanelState.close,
  })  : assert(0 <= backdropOpacity && backdropOpacity <= 1.0),
        assert(snapPoint == null || 0 < snapPoint && snapPoint < 1.0);
}
