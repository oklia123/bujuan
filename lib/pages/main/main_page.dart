import 'package:bujuan_music/pages/main/menu_page.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import '../../widgets/slide.dart';

class MainPage extends StatelessWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var of = MediaQuery.of(context);
    double minHeightBox = 45.w + (of.padding.bottom == 0?20.w:of.padding.bottom);
    double maxHeightBox = of.size.height - of.padding.top - 5.w;
    return Scaffold(
      body: ZoomDrawer(
          controller: GetIt.I<ZoomDrawerController>(),
          reverseDuration: Duration(milliseconds: 1000),
          menuScreen: MenuPage(),
          menuScreenWidth: MediaQuery.of(context).size.width,
          mainScreenScale: .18,
          angle: -8,
          slideWidth: 200.w,
          dragOffset: 200.w,
          shadowLayer1Color: Colors.grey.withAlpha(20),
          shadowLayer2Color: Colors.grey.withAlpha(30),
          showShadow: true,
          mainScreenTapClose: true,
          menuScreenTapClose: true,
          mainScreen: Consumer(builder: (context, ref, c) {
            var theme = ref.watch(themeModeNotifierProvider);
            return SlidingBox(
              controller: GetIt.I<BoxController>(),
              collapsed: true,
              minHeight: minHeightBox,
              maxHeight: maxHeightBox,
              color: Theme.of(context).scaffoldBackgroundColor,
              style: BoxStyle.sheet,
              draggableIconVisible: false,
              draggableIconBackColor: Colors.white,
              onBoxOpen: (){},
              onBoxSlide: (value) =>
                  ref.read(boxPanelDetailDataProvider.notifier).updatePanelDetail(value),
              backdrop: Backdrop(
                moving: false,
                color: Theme.of(context).scaffoldBackgroundColor,
                body: child,
              ),
              bodyBuilder: (s, _) => GestureDetector(
                child: PlayPage(),
                onHorizontalDragUpdate: (e) {},
              ),
            );
          })),
    );
  }
}

