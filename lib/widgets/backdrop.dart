import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BackdropView extends StatelessWidget {
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final Widget child;
  final EdgeInsets? padding;

  const BackdropView({
    super.key,
    this.padding,
    this.borderRadius,
    this.decoration,
    this.width,
    this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(30.w),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), //
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: decoration ??
              BoxDecoration(
                color: Colors.white.withAlpha(20), // 半透明背景
                borderRadius: BorderRadius.circular(30.w),
                border: Border.all(color: Colors.grey.withAlpha(40)),
              ),
          child: child,
        ),
      ),
    );
  }
}
