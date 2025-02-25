import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../widgets/slide.dart';

class MainPage extends ConsumerWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double minHeightBox = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom -
        MediaQuery.of(context).padding.top -
        76.w -
        80.w;
    double maxHeightBox = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom -
        MediaQuery.of(context).padding.top -
        80.w;
    return Scaffold(
      body: SlidingUpPanel(
        controller: ref.watch(panelControllerProvider),
        panelBuilder: () => PlayPage(),
        parallaxEnabled: true,
        parallaxOffset: 0.01,
        body: Padding(
          padding: EdgeInsets.only(bottom: 20.w),
          child: SlidingBox(
            controller: ref.watch(boxControllerProvider),
            minHeight: minHeightBox,
            maxHeight: maxHeightBox,
            color: Colors.white,
            style: BoxStyle.sheet,
            draggableIconBackColor: Colors.white,
            // draggableIconVisible: false,
            backdrop: Backdrop(
                fading: false,
                moving: false,
                color: Colors.white,
                body: _backdrop(context, ref),
                appBar: BackdropAppBar(
                    leading: HugeIcon(
                      icon: HugeIcons.strokeRoundedBorderFull,
                      color: Colors.black,
                      size: 26.sp,
                    ),
                    title: Text(
                      'Bujuan',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {},
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedSearch01,
                            color: Colors.black,
                            size: 24.sp,
                          )),
                    ])),
            body: child,
          ),
        ),
        // body: child,
        minHeight: 60.w,
        maxHeight: MediaQuery.of(context).size.height,
        onPanelSlide: (double value) {
          ref.read(slidingPanelDetailDataProvider.notifier).updatePanelDetail(value);
        },
      ),
    );
  }

  _backdrop(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(top: 50),
        height: MediaQuery.of(context).size.height,
        color: Colors.grey.withOpacity(.2),
        child: Consumer(builder: (context, ref, child) {
          var path = ref.watch(currentRouterPathProvider);
          GoRouter.of(context).routerDelegate.addListener((){});
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    ref.read(boxControllerProvider).openBox();
                    context.replace(AppRouter.playlist);
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedUser,
                    color: path == AppRouter.playlist ? Colors.red : Colors.black,
                    size: 24.sp,
                  )),
              TextButton(
                  onPressed: () {
                    ref.read(boxControllerProvider).openBox();
                    context.replace(AppRouter.home);
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedHome01,
                    color: path == AppRouter.home ? Colors.red : Colors.black,
                    size: 24.sp,
                  )),
              TextButton(
                  onPressed: () {
                    ref.read(boxControllerProvider).openBox();
                    context.replace(AppRouter.home);
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSettings02,
                    color: Colors.black,
                    size: 24.sp,
                  ))
            ],
          );
        }),
      ),
    );
  }
}
