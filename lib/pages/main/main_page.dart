import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/common/values/app_config.dart';
import 'package:bujuan_music/common/values/app_images.dart';
import 'package:bujuan_music/pages/main/menu_page.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music/widgets/backdrop.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:bujuan_music/widgets/rive_player.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../utils/adaptive_screen_utils.dart';
import 'package:rive_native/rive_native.dart' as rive;

import '../../widgets/we_slider/weslide.dart';
import '../../widgets/we_slider/weslide_controller.dart';

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
    // return ZoomDrawer(
    //     controller: GetIt.I<ZoomDrawerController>(),
    //     reverseDuration: Duration(milliseconds: 1000),
    //     menuScreen: MenuPage(),
    //     menuScreenWidth: MediaQuery.of(context).size.width,
    //     mainScreenScale: .18,
    //     angle: -8,
    //     slideWidth: 200.w,
    //     dragOffset: 200.w,
    //     shadowLayer1Color: Colors.grey.withAlpha(20),
    //     shadowLayer2Color: Colors.grey.withAlpha(30),
    //     showShadow: true,
    //     mainScreenTapClose: true,
    //     menuScreenTapClose: true,
    //     mainScreen: Consumer(builder: (context, ref, c) {
    //       return SlidingBox(
    //         controller: GetIt.I<BoxController>(),
    //         collapsed: true,
    //         minHeight: minHeightBox,
    //         maxHeight: maxHeightBox,
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         style: BoxStyle.sheet,
    //         draggableIconVisible: false,
    //         draggableIconBackColor: Colors.white,
    //         onBoxOpen: () {},
    //         onBoxSlide: (value) =>
    //             ref.read(boxPanelDetailDataProvider.notifier).updatePanelDetail(value),
    //         backdrop: Backdrop(
    //           moving: false,
    //           color: Theme.of(context).scaffoldBackgroundColor,
    //           body: child,
    //         ),
    //         bodyBuilder: (s, _) => GestureDetector(
    //           child: PlayPage(),
    //           onHorizontalDragUpdate: (e) {},
    //         ),
    //       );
    //     }));
    // return Consumer(builder: (context, ref, c) {
    //   return SlidingBox(
    //     controller: GetIt.I<BoxController>(),
    //     collapsed: true,
    //     minHeight: minHeightBox,
    //     maxHeight: maxHeightBox,
    //     color: Theme.of(context).scaffoldBackgroundColor,
    //     style: BoxStyle.sheet,
    //     draggableIconVisible: false,
    //     draggableIconBackColor: Colors.white,
    //     onBoxOpen: () {},
    //     onBoxSlide: (value) =>
    //         ref.read(boxPanelDetailDataProvider.notifier).updatePanelDetail(value),
    //     backdrop: Backdrop(
    //       moving: false,
    //       color: Theme.of(context).scaffoldBackgroundColor,
    //       body: child,
    //     ),
    //     bodyBuilder: (s, _) => GestureDetector(
    //       child: PlayPage(),
    //       onHorizontalDragUpdate: (e) {},
    //     ),
    //   );
    // });
    var of2 = MediaQuery.of(context);
    final double panelMinSize = 72.w + 56 + of2.padding.bottom;
    final double panelMaxSize = of2.size.height - of2.padding.top;
    var panelController = GetIt.I<WeSlideController>(instanceName: 'panel');
    var theme = Theme.of(context);
    return WeSlide(
      panelBorderRadiusBegin: 0,
      panelBorderRadiusEnd: 20.w,
      backgroundColor: Colors.transparent,
      panelMinSize: panelMinSize,
      panelMaxSize: panelMaxSize,
      panelWidth: of2.size.width,
      hideFooter: true,
      footerController: GetIt.I<WeSlideController>(instanceName: 'footer'),
      controller: panelController,
      body: child,
      panel: PlayPage(),
      panelHeader: GestureDetector(
        child: SongInfoBar(),
        onTap: () {
          panelController.show();
        },
      ),
      footerHeight: 65 + of2.padding.bottom,
      footer: Consumer(builder: (context, ref, child) {
        return BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: ref.watch(currentIndexProvider),
          items: AppConfig.bottomItems.map((e) {
            return BottomNavigationBarItem(
                icon: Icon(e.iconData),
                label: '•',
                backgroundColor: theme.scaffoldBackgroundColor);
          }).toList(),
          onTap: (index) {
            ref.read(currentIndexProvider.notifier).setIndex(index);
            context.replace(AppConfig.bottomItems[index].path);
          },
        );
      }),
    );
  }
}

class BottomData {
  IconData iconData;
  String path;

  BottomData(this.iconData, this.path);
}

class DesktopView extends StatelessWidget {
  final Widget child;

  const DesktopView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var of = MediaQuery.of(context);
    return SizedBox(
      width: of.size.width,
      height: of.size.height,
      child: Stack(
        children: [
          Consumer(builder: (context, ref, child) {
            var watch = ref.watch(backgroundModeNotifierProvider);
            return RivePlayer(
              asset: watch,
              fit: rive.Fit.cover,
              autoBind: true,
            );
          }),
          Column(
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
                  Expanded(child: BackdropView(child: child)),
                  SizedBox(width: 10.w),
                ],
              )),
              SizedBox(height: 10.w),
              _buildBottomBar(context),
              SizedBox(height: 10.w),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return GestureDetector(
      child: BackdropView(
        height: 52.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Wrap(
          runAlignment: WrapAlignment.center,
          children: [
            IconButton(
                onPressed: () => BujuanMusicHandler().skipToPrevious(),
                icon: Icon(
                  HugeIcons.strokeRoundedPrevious,
                  size: 22.sp,
                )),
            SizedBox(width: 10.w),
            Consumer(builder: (context, ref, child) {
              var playbackState = ref.watch(playbackStateProvider).value;
              return IconButton(
                  onPressed: () => BujuanMusicHandler().playOrPause(),
                  icon: Icon(
                    (playbackState?.playing ?? false)
                        ? HugeIcons.strokeRoundedPause
                        : HugeIcons.strokeRoundedPlay,
                    size: 22.sp,
                  ));
            }),
            SizedBox(width: 10.w),
            IconButton(
                onPressed: () => BujuanMusicHandler().skipToNext(),
                icon: Icon(
                  HugeIcons.strokeRoundedNext,
                  size: 22.sp,
                )),
            SizedBox(width: 15.w),
            Container(
              height: 40.w,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(20), borderRadius: BorderRadius.circular(30.w)),
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
                    SizedBox(width: 20.w),
                    Text(
                      media?.title ?? 'Bujuan',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 15.w),
                    IconButton(onPressed: () {}, icon: Icon(HugeIcons.strokeRoundedFavourite)),
                  ],
                );
              }),
            ),
            SizedBox(width: 10.w),
            IconButton(onPressed: () {}, icon: Icon(HugeIcons.strokeRoundedVolumeHigh))
          ],
        ),
      ),
      onTap: () {
        var path = GoRouter.of(context).state.path;
        if (path == AppRouter.play) {
          context.pop();
          return;
        }
        context.push(AppRouter.play);
      },
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
              Text('Search Any...')
            ],
          ),
        )
      ],
    );
  }
}
