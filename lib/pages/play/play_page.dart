import 'package:bujuan_music/widgets/curved_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../main/provider.dart';

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> _sizeAnimation;
  late Animation<Offset> _coverPositionAnimation;

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    _sizeAnimation = Tween<double>(begin: 50.w, end: 280.w).animate(animationController);
    _coverPositionAnimation =
        Tween<Offset>(begin: Offset(10.w, 10.w), end: Offset((375.w - 10.w - 280.w) / 2, 50.w))
            .animate(animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(slidingPanelDetailDataProvider);
    double top = MediaQuery.of(context).padding.top;
    animationController.value = watch;
    return Column(
      children: [
        SizedBox(
          height: 330.w + top,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Positioned(
                    left: _coverPositionAnimation.value.dx,
                    top: _coverPositionAnimation.value.dy + top * animationController.value,
                    child: GestureDetector(
                      child: Image.asset(
                        'assets/images/cover.png',
                        width: _sizeAnimation.value,
                        height: _sizeAnimation.value,
                      ),
                      onTap: (){
                        ref.watch(panelControllerProvider).open();
                      },
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Positioned(
                    left: 0,
                    top:
                    -50.w * (1 - animationController.value) + top * animationController.value,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      height: 50.w,
                      width: 375.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down_outlined,
                            size: 26.sp,
                          ),
                          Icon(
                            Icons.more_horiz,
                            size: 26.sp,
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 15.h)),
        Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Text(
                    'Lucky Strike',
                    style:
                    TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 3.h)),
                  Text(
                    'Troy Sivan',
                    style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CurvedProgressBar(
                            progress: .4,
                            progressColor: Colors.grey.withOpacity(.5),
                            activeProgressColor: Colors.red,
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 4.h)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '01:24',
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '04:27',
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        ],
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/shuffle.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 15.w)),
                      Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                'assets/images/left.png',
                                width: 24.w,
                                height: 24.w,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.red, borderRadius: BorderRadius.circular(22.w)),
                                width: 44.w,
                                height: 44.w,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 28.sp,
                                ),
                              ),
                              Image.asset(
                                'assets/images/right.png',
                                width: 24.w,
                                height: 24.w,
                              ),
                            ],
                          )),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 15.w)),
                      Image.asset(
                        'assets/images/cycle.png',
                        width: 24.w,
                        height: 24.w,
                      )
                    ],
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 25.h)),
                ],
              ),
            ))
      ],
    );
  }
}
