import 'package:bujuan_music/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';

import '../pages/main/provider.dart';

class SlidingBox extends StatefulWidget {
  SlidingBox({
    super.key,
    this.controller,
    this.width,
    this.minHeight = 200,
    this.maxHeight = 400,
    this.color = Colors.white,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(25),
      topRight: Radius.circular(25),
    ),
    this.style = BoxStyle.none,
    this.body,
    this.bodyBuilder,
    this.physics = const BouncingScrollPhysics(),
    this.draggable = true,
    this.draggableIcon = Icons.remove_rounded,
    this.draggableIconColor = const Color(0xff9a9a9a),
    this.draggableIconVisible = true,
    this.draggableIconBackColor = const Color(0x22777777),
    this.collapsed = false,
    this.animationCurve = Curves.fastOutSlowIn,
    this.animationDuration = const Duration(milliseconds: 100),
    this.backdrop,
    this.onBoxSlide,
    this.onBoxClose,
    this.onBoxOpen,
    this.onBoxHide,
    this.onBoxShow,
    this.onSearchBoxHide,
    this.onSearchBoxShow,
  }) : assert(
          backdrop?.appBar?.leading == null || controller != null,
          "controller must not be null",
        );

  /// It can be used to control the state of sliding box and search box.
  final BoxController? controller;

  /// The [width] of the sliding box.
  final double? width;

  /// The height of the sliding box when fully [collapsed].
  final double? minHeight;

  /// The height of the sliding box when fully opened.
  final double? maxHeight;

  /// The [color] to fill the background of the sliding box.
  final Color? color;

  /// The corners of the sliding box are rounded by this.
  final BorderRadius? borderRadius;

  /// The styles behind of the sliding box that includes shadow, sheet, none.
  final BoxStyle? style;

  /// A widget that slides from [minHeight] to [maxHeight] and is placed on the
  /// backdrop.
  final Widget? body;

  /// Provides a ScrollController to attach to a scrollable widget in the box
  /// and current box position. If [body] and [bodyBuilder] are both non-null,
  /// [body] will be used.
  final Widget Function(
    ScrollController scrollController,
    double boxPosition,
  )? bodyBuilder;

  /// Gets a ScrollPhysic, the [physics] determines how the scroll view
  /// continues to animate after the user stops dragging the scroll view.
  final ScrollPhysics? physics;

  /// Allows toggling of draggability of the sliding box. if set this to false,
  /// the sliding box cannot be dragged up or down.
  final bool? draggable;

  /// A Icon Widget that is placed in top of the box.
  /// Gets a IconData.
  final IconData? draggableIcon;

  /// The color of the [draggableIcon].
  /// the position of the icon is top of the box.
  final Color? draggableIconColor;

  /// If set to false, the [draggableIcon] hides. Use the controller to
  /// open and close sliding box by taps.
  final bool? draggableIconVisible;

  /// The color to fill the background of the [draggableIcon] icon.
  /// the position of the icon is top of the box.
  final Color? draggableIconBackColor;

  /// If set to true, the state of the box is [collapsed].
  final bool? collapsed;

  /// The [animationCurve] defines the easier behavior of the box animation.
  final Curve? animationCurve;

  /// The [animationDuration] defines the time for the box animation to
  /// complete.
  final Duration? animationDuration;

  /// A Widget that is placed under the box, the value should be filled with
  /// the [Backdrop] object.
  final Backdrop? backdrop;

  /// This callback is called when the sliding box slides around with position
  /// of the box. the position is a double value between 0.0 and 1.0,
  /// where 0.0 is fully collapsed and 1.0 is fully opened.
  final ValueChanged<double>? onBoxSlide;

  /// This callback is called when the sliding box is fully closed.
  final VoidCallback? onBoxClose;

  /// This callback is called when the sliding box is fully opened.
  final VoidCallback? onBoxOpen;

  /// This callback is called when the sliding box is invisible.
  final VoidCallback? onBoxHide;

  /// This callback is called when the sliding box is visible.
  final VoidCallback? onBoxShow;

  /// This callback is called when the search box is invisible.
  final VoidCallback? onSearchBoxHide;

  /// This callback is called when the search box is visible.
  final VoidCallback? onSearchBoxShow;

  @override
  State<SlidingBox> createState() => _SlidingBoxState();
}

class _SlidingBoxState extends State<SlidingBox> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late ScrollController _scrollController;
  late double _boxWidth;
  late double _backdropWidth;
  bool _isBoxVisible = true;
  bool _isBoxOpen = true;
  bool _isBoxAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.animationDuration,
      value: widget.collapsed == true ? 0.0 : 1.0,
    )..addListener(() {
        if (widget.onBoxSlide != null) {
          widget.onBoxSlide!.call(_animationController.value);
        }
        if (widget.onBoxClose != null && _isBoxOpen && _animationController.value == 0.0) {
          widget.onBoxClose!.call();
        }
        if (widget.onBoxOpen != null && !_isBoxOpen && _animationController.value == 1.0) {
          widget.onBoxOpen!.call();
        }
      });
    _scrollController = ScrollController();
    _isBoxOpen = !widget.collapsed!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _boxWidth = widget.width ?? MediaQuery.of(context).size.width;
    _backdropWidth = widget.backdrop?.width ?? MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null) widget.controller!._addState(this);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (widget.backdrop != null) _backdrop(),
        if (_isBoxVisible == true) _body(),
      ],
    );
  }

  /// Returns a Widget that placed in [Backdrop.body].
  Widget _backdrop() {
    return _gestureHandler(
      dragUpdate: widget.draggable!,
      dragEnd: widget.draggable!,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) {
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: _backdropWidth,
              height: MediaQuery.of(context).size.height,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      widget.backdrop?.backgroundGradient == null ? widget.backdrop?.color : null,
                  gradient: widget.backdrop?.backgroundGradient,
                ),
                child: Stack(
                  children: [
                    Container(
                      transform: widget.backdrop!.moving == true
                          ? Matrix4.translationValues(
                              0.0,
                              -((_animationController.value *
                                      ((widget.maxHeight! -
                                              MediaQuery.of(context).viewInsets.bottom) -
                                          widget.minHeight!)) *
                                  0.08),
                              0.0,
                            )
                          : null,
                      margin: EdgeInsets.only(
                        bottom: _isBoxVisible
                            ? widget.minHeight! > 0
                                ? widget.minHeight! - 25
                                : 0
                            : 0,
                      ),
                      child: widget.backdrop!.fading == true
                          ? AnimatedOpacity(
                              duration: Duration(milliseconds: 250),
                              opacity: 1.0 - _animationController.value,
                              child: widget.backdrop!.body,
                            )
                          : widget.backdrop!.body,
                    ),
                    if (widget.backdrop?.overlay == true)
                      GestureDetector(
                        onTap: _onGestureTap,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (_, child) {
                            if (_animationController.value > 0.0) {
                              return AnimatedOpacity(
                                duration: Duration(milliseconds: 250),
                                opacity: _animationController.value,
                                child: Container(
                                  color: Colors.black.withAlpha(
                                    (widget.backdrop!.overlayOpacity! * 255).toInt(),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      ),
                    if (widget.backdrop?.appBar != null)
                      GestureDetector(
                        // onTap: _onGestureTap,
                        onTap: () {
                          GetIt.I<ZoomDrawerController>().toggle?.call();
                        },
                        onVerticalDragUpdate: (e) {},
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top, left: 12, right: 6),
                          child: Row(
                            children: [
                              if (_isBoxVisible && widget.backdrop?.appBar?.leading != null)
                                widget.backdrop?.appBar?.leading ?? const SizedBox.shrink(),
                              // ValueListenableBuilder<MenuIconValue>(
                              //   valueListenable: widget.controller!,
                              //   builder: (_, value, __) {
                              //     return AnimatedSwitcher(
                              //       duration: const Duration(
                              //         milliseconds: 250,
                              //       ),
                              //       child: Icon(
                              //         key: ValueKey<bool>(value.isOpenMenuIcon!),
                              //         size: widget.backdrop?.appBar?.leading?.size,
                              //         color: widget.backdrop?.appBar?.leading?.color,
                              //           widget.backdrop?.appBar?.leading?.icon
                              //         // !value.isOpenMenuIcon!
                              //         //     ? widget.backdrop?.appBar?.leading?.icon
                              //         //     : HugeIcons.strokeRoundedBorderFull,
                              //       ),
                              //     );
                              //   },
                              // ),
                              SizedBox(width: 12),
                              if (widget.backdrop?.appBar?.title != null)
                                widget.backdrop!.appBar!.title!,
                              Spacer(),
                              if (widget.backdrop?.appBar?.actions != null)
                                ...widget.backdrop!.appBar!.actions ?? [],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Returns a Widget that placed in [SlidingBox.body].
  Widget _body() {
    return _gestureHandler(
      dragUpdate: widget.draggable!,
      dragEnd: widget.draggable!,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) {
          return Stack(
            children: <Widget>[
              if (widget.style == BoxStyle.sheet)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: _boxWidth,
                    height: _animationController.value *
                            ((widget.maxHeight! - MediaQuery.of(context).viewInsets.bottom) -
                                widget.minHeight!) +
                        widget.minHeight! +
                        12,
                    child: Center(
                      child: Consumer(
                        builder: (context, ref, child) {
                          var theme = ref.watch(themeModeNotifierProvider);
                          return Container(
                            width: _boxWidth - 15,
                            decoration: BoxDecoration(
                              borderRadius: widget.borderRadius,
                              color: ColorUtils.lightenColor(
                                  theme == ThemeMode.light ? Color(0xFFF3EEEE) : Colors.black,
                                  theme == ThemeMode.light ? 0.6 : 0.25),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.grey.withAlpha(
                              //       widget.minHeight! > 0
                              //           ? 60
                              //           : (_animationController.value * 60).toInt(),
                              //     ),
                              //     spreadRadius: 6,
                              //     blurRadius: 6,
                              //     offset: const Offset(0, 8),
                              //   ),
                              // ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: _boxWidth,
                  height: _animationController.value *
                          ((widget.maxHeight! - MediaQuery.of(context).viewInsets.bottom) -
                              widget.minHeight!) +
                      widget.minHeight!,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: widget.borderRadius!.topLeft,
                      topRight: widget.borderRadius!.topRight,
                      bottomLeft: Radius.circular(
                        (1.0 - _animationController.value) * widget.borderRadius!.bottomLeft.y,
                      ),
                      bottomRight: Radius.circular(
                        (1.0 - _animationController.value) * widget.borderRadius!.bottomLeft.y,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(
                          widget.minHeight! > 0 ? 40 : (_animationController.value * 60).toInt(),
                        ),
                        spreadRadius: 6,
                        blurRadius: 6,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    color: widget.color,
                    child: Stack(
                      children: [
                        if (widget.draggableIconVisible! && widget.draggable!)
                          GestureDetector(
                            onTap: _onGestureTap,
                            child: Container(
                              width: _boxWidth,
                              height: 30,
                              color: widget.draggableIconBackColor,
                              child: Transform(
                                transform: Matrix4.translationValues(0, -15, 0),
                                child: Icon(
                                  widget.draggableIcon,
                                  color: widget.draggableIconColor,
                                  size: 62,
                                ),
                              ),
                            ),
                          ),
                        Container(
                          padding: widget.draggableIconVisible! && widget.draggable!
                              ? const EdgeInsets.only(top: 30)
                              : null,
                          // child: widget.body,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const NeverScrollableScrollPhysics(),
                            child: widget.body != null
                                ? widget.body!
                                : widget.bodyBuilder != null
                                    ? widget.bodyBuilder!(
                                        _scrollController,
                                        _boxPosition,
                                      )
                                    : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Returns a gesture detector when user dragging on the box or backdrop.
  Widget _gestureHandler({
    required Widget child,
    bool dragUpdate = false,
    bool dragEnd = false,
    bool onTap = false,
  }) {
    return GestureDetector(
      onVerticalDragUpdate:
          dragUpdate ? (DragUpdateDetails details) => _onGestureUpdate(details.delta.dy) : null,
      onVerticalDragEnd:
          dragEnd ? (DragEndDetails details) => _onGestureEnd(details.velocity) : null,
      onTap: () => onTap ? _onGestureTap() : null,
      child: child,
    );
  }

  /// handles when user dragging the sliding box.
  void _onGestureUpdate(double dy) {
    if (_isBoxAnimating == true) return;
    _animationController.value -=
        dy / ((widget.maxHeight! - MediaQuery.of(context).viewInsets.bottom) - widget.minHeight!);
    if (widget.controller == null) return;
    if (_animationController.value == 1.0) {
      widget.controller!.openBox();
    } else if (_animationController.value == 0.0) {
      widget.controller!.closeBox();
    }
  }

  /// handles when user stops sliding.
  void _onGestureEnd(Velocity v) {
    if (_isBoxAnimating == true) return;
    _isBoxAnimating = true;
    if (v.pixelsPerSecond.dy > 0 &&
        v.pixelsPerSecond.dy > (widget.maxHeight! - MediaQuery.of(context).viewInsets.bottom)) {
      _animationController
          .animateTo(
            0.0,
            duration: widget.animationDuration,
            curve: widget.animationCurve!,
          )
          .then((_) => _isBoxAnimating = false)
          .then((_) {
        if (widget.controller != null) widget.controller!.closeBox();
      });
    } else if (v.pixelsPerSecond.dy < 0 &&
        v.pixelsPerSecond.dy < -(widget.maxHeight! - MediaQuery.of(context).viewInsets.bottom)) {
      _animationController
          .animateTo(
            1.0,
            duration: widget.animationDuration,
            curve: widget.animationCurve!,
          )
          .then((_) => _isBoxAnimating = false)
          .then((_) {
        if (widget.controller != null) widget.controller!.openBox();
      });
    } else {
      if (_animationController.value < 0.7) {
        _animationController
            .animateTo(
              0.0,
              duration: widget.animationDuration,
              curve: widget.animationCurve!,
            )
            .then((_) => _isBoxAnimating = false)
            .then((_) {
          if (widget.controller != null) widget.controller!.closeBox();
        });
      } else {
        _animationController
            .animateTo(
              1.0,
              duration: widget.animationDuration,
              curve: widget.animationCurve!,
            )
            .then((_) => _isBoxAnimating = false)
            .then((_) {
          if (widget.controller != null) widget.controller!.openBox();
        });
      }
    }
  }

  /// handles when user tap on sliding box.
  void _onGestureTap() {
    if (_isBoxAnimating == true) return;
    widget.controller != null && widget.controller!.isBoxOpen
        ? widget.controller?.closeBox()
        : widget.controller?.openBox();
  }

  ///---------------------------------
  ///BoxController related functions
  ///---------------------------------

  /// Closes the sliding box with animation (i.e. to the SlidingBox.maxHeight).
  Future<void> _closeBox() async {
    if (!_isBoxVisible) return;
    return _animationController.fling(velocity: -1.0).then((_) {
      setState(() {
        _isBoxOpen = false;
      });
      // if (_isSearchBoxVisible && widget.controller != null) widget.controller!.hideSearchBox();
    });
  }

  /// Opens the sliding box with animation (i.e. to the [SlidingBox.maxHeight]).
  Future<void> _openBox() async {
    if (!_isBoxVisible) return;
    return _animationController.fling(velocity: 1.0).then((_) {
      setState(() {
        _isBoxOpen = true;
      });
    });
  }

  /// Hides [SlidingBox.body] (i.e. is invisible).
  Future<void> _hideBox() {
    return _animationController.fling(velocity: -1.0).then((_) {
      setState(() {
        _isBoxVisible = false;
      });
      if (widget.onBoxHide != null) {
        widget.onBoxHide!.call();
      }
    });
  }

  /// Shows [SlidingBox.body] (i.e. is visible).
  Future<void> _showBox() {
    setState(() {
      _isBoxVisible = true;
    });
    if (widget.onBoxShow != null) {
      widget.onBoxShow!.call();
    }
    return _animationController.fling(velocity: 1.0);
  }

  /// Sets current box position.
  Future<void> _setPosition(double value) {
    assert(0.0 <= value && value <= 1.0);
    return _animateBoxToPosition(value).then((_) {
      _boxPosition = value;
    });
  }

  /// Animate the box position to value - value must between 0.0 and 1.0.
  Future<void> _animateBoxToPosition(double value) {
    assert(0.0 <= value && value <= 1.0);
    return _animationController.animateTo(
      value,
      duration: widget.animationDuration,
      curve: widget.animationCurve!,
    );
  }

  /// Sets current box position.
  set _boxPosition(double value) {
    assert(0.0 <= value && value <= 1.0);
    _animationController.value = value;
  }

  /// Gets current box position.
  double get _boxPosition => _animationController.value;

  /// Gets current box [SlidingBox.minHeight].
  double get _minHeight => widget.minHeight!;

  /// Gets current box [SlidingBox.maxHeight].
  double get _maxHeight => widget.maxHeight!;

  /// Gets current box [SlidingBox.width].
  double get _boxBodyWidth => _boxWidth;

  /// Gets current box [Backdrop.width].
  double get _backdropBodyWidth => _backdropWidth;
}

class MenuIconValue {
  const MenuIconValue({this.isOpenMenuIcon = false});

  final bool? isOpenMenuIcon;

  /// Create a value with close icon menu state.
  factory MenuIconValue.closeMenu() {
    return const MenuIconValue(isOpenMenuIcon: false);
  }

  /// Create a value with open icon menu state.
  factory MenuIconValue.openMenu() {
    return const MenuIconValue(isOpenMenuIcon: true);
  }
}

class BoxController extends ValueNotifier<MenuIconValue> {
  BoxController() : super(const MenuIconValue());

  _SlidingBoxState? _boxState;

  void _addState(_SlidingBoxState boxState) {
    _boxState = boxState;
  }

  /// Determine if the [SlidingBox.controller] is attached to an instance of the
  /// [SlidingBox] (this property must be true before any other [BoxController]
  /// functions can be used).
  bool get isAttached => _boxState != null;

  /// Closes the sliding box with animation.
  /// (i.e. to the [SlidingBox.minHeight]).
  Future<void> closeBox() async {
    try {
      assert(isAttached, "BoxController must be attached to a SlidingBox");
      value = MenuIconValue.openMenu();
      return _boxState!._closeBox().then((_) => notifyListeners());
    } catch (e) {
      return;
    }
  }

  /// Opens the sliding box with animation.
  /// (i.e. to the [SlidingBox.maxHeight]).
  Future<void> openBox() async {
    try {
      assert(isAttached, "BoxController must be attached to a SlidingBox");
      value = MenuIconValue.closeMenu();
      return _boxState!._openBox().then((_) => notifyListeners());
    } catch (e) {
      return;
    }
  }

  /// Hides the sliding box (i.e. is invisible).
  Future<void> hideBox() async {
    try {
      assert(isAttached, "BoxController must be attached to a SlidingBox");
      return _boxState!._hideBox();
    } catch (e) {
      return;
    }
  }

  /// Shows the sliding box (i.e. is visible).
  Future<void> showBox() async {
    try {
      assert(isAttached, "BoxController must be attached to a SlidingBox");
      return _boxState!._showBox();
    } catch (e) {
      return;
    }
  }

  /// Shows the search box (i.e. is visible).
  Future<void> showSearchBox() async {
    try {
      assert(isAttached, "BoxController must be attached to a SlidingBox");
      // return _boxState!._showSearchBox();
    } catch (e) {
      return;
    }
  }

  Future<void> setPosition(double value) async {
    try {
      assert(isAttached, "BoxController must be attached to a SlidingBox");
      assert(0.0 <= value && value <= 1.0);
      return _boxState!._setPosition(value);
    } catch (e) {
      return;
    }
  }

  /// Returns current box position (a value between 0.0 and 1.0).
  double get getPosition {
    assert(isAttached, "BoxController must be attached to a SlidingBox");
    return _boxState!._boxPosition;
  }

  /// Returns whether or not the box is open.
  bool get isBoxOpen {
    assert(isAttached, "BoxController must be attached to a SlidingBox");
    return _boxState!._isBoxOpen;
  }

  /// Returns whether or not the box is close or collapsed.
  bool get isBoxClosed {
    assert(isAttached, "BoxController must be attached to a SlidingBox");
    return !_boxState!._isBoxOpen;
  }

  /// Returns whether or not the box is visible.
  bool get isBoxVisible {
    assert(isAttached, "BoxController must be attached to a SlidingBox");
    return _boxState!._isBoxVisible;
  }

  /// Returns current box [SlidingBox.minHeight].
  double get minHeight {
    assert(isAttached, "BoxController must be attached to a SlidingBox");
    return _boxState!._minHeight;
  }

  /// Returns current box [SlidingBox.maxHeight].
  double get maxHeight {
    assert(isAttached, "BoxController must be attached to a SlidingBox");
    return _boxState!._maxHeight;
  }

  /// Returns current box [SlidingBox.width].
  double get boxWidth {
    assert(isAttached, "BoxController must be attached to a SlidingBox");
    return _boxState!._boxBodyWidth;
  }

  /// Returns current backdrop box [Backdrop.width].
  double get backdropWidth {
    assert(isAttached, "BoxController must be attached to a SlidingBox");
    return _boxState!._backdropBodyWidth;
  }
}

enum BoxStyle {
  none,
  shadow,
  sheet,
}

class Backdrop {
  const Backdrop({
    this.width,
    this.fading = false,
    this.moving = true,
    this.overlay = false,
    this.overlayOpacity = 0.5,
    this.color,
    this.backgroundGradient,
    this.appBar,
    this.body,
  }) : assert(
          overlayOpacity != null && 0.0 <= overlayOpacity && overlayOpacity <= 1.0,
          "overlayOpacity double value must between 0.0 and 1.0",
        );

  /// The width of the backdrop [body].
  final double? width;

  /// If set to true, the backdrop [body] moving up when the sliding box opened.
  final bool? moving;

  /// If set to true, the backdrop [body] fades out when the sliding box opened.
  final bool? fading;

  /// If set to true, a dark layer displayed overtop the backdrop when
  /// sliding box opened.
  final bool? overlay;

  /// The value of the dark layer overtop the backdrop. a double value between
  /// 0.0 and 1.0.
  final double? overlayOpacity;

  /// The [color] to fill the background of the backdrop [body].
  final Color? color;

  /// The gradient color to fill the background of the backdrop. if [color] and
  /// [backgroundGradient] are both non-null, [color] will be used.
  final Gradient? backgroundGradient;

  /// An app bar to display at the top of the [SlidingBox.backdrop].
  final BackdropAppBar? appBar;

  /// A Widget that is placed in the [SlidingBox.backdrop] and behind
  /// the sliding box.
  final Widget? body;
}

class BackdropAppBar {
  const BackdropAppBar({
    this.title,
    this.leading,
    this.actions,
  });

  /// A Widget that is placed on the topLeft of the [SlidingBox.backdrop].
  final Widget? title;

  /// A [Icon] Widget that is placed in left of the BackdropAppBar [title].
  final Widget? leading;

  /// An search box to display at the top of the [SlidingBox.backdrop].
  /// if non-null, an search Icon displayed on topRight of the backdrop.

  /// A list of Widgets that is placed on the topRight of the
  /// [SlidingBox.backdrop].
  final List<Widget>? actions;
}
