import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class MainPage extends ConsumerWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double bottom = MediaQuery.of(context).padding.bottom;
    if (bottom == 0) bottom = 20.h;
    return Scaffold(
      body: ZoomDrawer(
          menuBackgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(.1),
          slideWidth: MediaQuery.of(context).size.width * .6,
          menuScreenWidth: MediaQuery.of(context).size.width * .6,
          mainScreenScale: 0.2,
          showShadow: true,
          mainScreenTapClose: true,
          menuScreenTapClose: true,
          androidCloseOnBackTap: true,
          drawerShadowsBackgroundColor: const Color(0xFFBEBBBB),
          menuScreen: Container(),
          mainScreen: SlidingUpPanel(
            controller: ref.watch(panelControllerProvider),
            panel: PlayPage(),
            body: child,
            options: SlidingUpPanelOptions(
              initialMinHeight: 60.w,
              initialMaxHeight: MediaQuery.of(context).size.height,
            ),
            onPanelSlide: (double value) {
              ref.read(slidingPanelDetailDataProvider.notifier).updatePanelDetail(value);
            },
          )),
    );
  }
}

//开关 旋钮
