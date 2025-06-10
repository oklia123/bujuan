import 'dart:ui';

import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/common/values/app_images.dart';
import 'package:bujuan_music/pages/main/menu_page.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:bujuan_music/widgets/backdrop.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../utils/adaptive_screen_utils.dart';
import '../../widgets/slide.dart';

class MainPage extends StatelessWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool desktop = medium(context) || expanded(context);
    return Scaffold(
      body: desktop ? DesktopView(child: child) : MobileView(child: child),
    );
  }
}

class MobileView extends StatelessWidget {
  final Widget child;

  const MobileView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var of = MediaQuery.of(context);
    double minHeightBox = 45.w + (of.padding.bottom == 0 ? 20.w : of.padding.bottom);
    double maxHeightBox = of.size.height - of.padding.top - 5.w;
    return ZoomDrawer(
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
          return SlidingBox(
            controller: GetIt.I<BoxController>(),
            collapsed: true,
            minHeight: minHeightBox,
            maxHeight: maxHeightBox,
            color: Theme.of(context).scaffoldBackgroundColor,
            style: BoxStyle.sheet,
            draggableIconVisible: false,
            draggableIconBackColor: Colors.white,
            onBoxOpen: () {},
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
        }));
  }
}

class DesktopView extends StatelessWidget {
  final Widget child;

  const DesktopView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var of = MediaQuery.of(context);
    return Container(
      width: of.size.width,
      height: of.size.height,
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover)),
      child: Column(
        children: [
          SizedBox(height: 10.w),
          _buildSearch(),
          SizedBox(height: 10.w),
          Expanded(
              child: Row(
            children: [
              SizedBox(width: 10.w),
              MenuPage(),
              SizedBox(width: 10.w),
              Expanded(
                  child: BackdropView(child: child)),
              SizedBox(width: 10.w),
            ],
          )),
          SizedBox(height: 10.w),
          _buildBottomBar(),
          SizedBox(height: 10.w),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BackdropView(
      height: 55.w,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Wrap(
        runAlignment: WrapAlignment.center,
        children: [
          IconButton(
              onPressed: ()  => BujuanMusicHandler().skipToPrevious(),
              icon: Icon(
                HugeIcons.strokeRoundedPrevious,
                size: 22.sp,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                HugeIcons.strokeRoundedPause,
                size: 22.sp,
              )),
          IconButton(
              onPressed: ()  => BujuanMusicHandler().skipToNext(),
              icon: Icon(
                HugeIcons.strokeRoundedNext,
                size: 22.sp,
              )),
          SizedBox(width: 15.w),
          Container(
            height: 40.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
                color: Colors.grey.withAlpha(100), borderRadius: BorderRadius.circular(30.w)),
            child: Consumer(builder: (context, ref, child) {
              var media = ref.watch(mediaItemProvider).value;
              return Wrap(
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CachedImage(
                    imageUrl: media?.artUri.toString() ?? '',
                    width: 30.w,
                    height: 30.w,
                    borderRadius: 23.w,
                  ),
                  SizedBox(width: 15.w),
                  Text(
                    media?.title ?? '',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(width: 15.w),
                  Icon(HugeIcons.strokeRoundedAudioWave01),
                  SizedBox(width: 15.w),
                  Icon(HugeIcons.strokeRoundedMoreHorizontal)
                ],
              );
            }),
          ),
          SizedBox(width: 10.w),
          IconButton(onPressed: () {}, icon: Icon(HugeIcons.strokeRoundedAiAudio))
        ],
      ),
    );
  }


  Widget _buildMenu() {
    return BackdropView(
      width: 50.w,
      padding: EdgeInsets.symmetric(vertical: 15.w),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(HugeIcons.strokeRoundedHome01),
          ),
          SizedBox(height: 50.w),
          IconButton(
            onPressed: () {},
            icon: Icon(HugeIcons.strokeRoundedUser),
          ),
          SizedBox(height: 50.w),
          IconButton(
            onPressed: () {},
            icon: Icon(HugeIcons.strokeRoundedNote),
          ),
          SizedBox(height: 50.w),
          IconButton(
            onPressed: () {},
            icon: Icon(HugeIcons.strokeRoundedSettings02),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(AppImages.logo, width: 45.w, height: 45.w),
        SizedBox(width: 10.w),
        BackdropView(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          height: 46.w,
          width: 460.w,
          child: Row(
            children: [
              Icon(HugeIcons.strokeRoundedAiSearch02),
              SizedBox(width: 15.w),
              Text('Search Any...', style: TextStyle(color: Colors.grey))
            ],
          ),
        )
      ],
    );
  }
}
