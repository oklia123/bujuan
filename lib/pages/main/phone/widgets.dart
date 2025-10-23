import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../../common/bujuan_music_handler.dart';
import '../../../common/values/app_config.dart';
import '../../../utils/color_utils.dart';
import '../../../widgets/backdrop.dart';
import '../../../widgets/cache_image.dart';
import '../../../widgets/we_slider/weslide.dart';
import '../../../widgets/we_slider/weslide_controller.dart';
import '../../play/play_page.dart';
import '../menu_page.dart';
import '../provider.dart';
import '../../../router/app_router.dart';

class SliderWidget extends StatelessWidget {
  final bool showBottomBar;
  final Widget child;

  const SliderWidget({super.key, required this.showBottomBar, required this.child});

  @override
  Widget build(BuildContext context) {
    var of2 = MediaQuery.of(context);
    final double panelMinSize = showBottomBar
        ? 64.w + 65 + of2.padding.bottom
        : 64.w + of2.padding.bottom / (Platform.isAndroid ? 1 : 1.3);
    final double panelMaxSize = of2.size.height - of2.padding.top;
    var panelController = GetIt.I<WeSlideController>(instanceName: 'panel');
    var footerController = GetIt.I<WeSlideController>(instanceName: 'footer');
    var theme = Theme.of(context);

    // 构造用于展示的底部导航项，过滤掉 path == AppRouter.home 的项（隐藏 Home）
    final displayBottomItems =
        AppConfig.bottomItems.where((e) => e.path != AppRouter.home).toList();

    return WeSlide(
      panelBorderRadiusBegin: 0,
      panelBorderRadiusEnd: 20.w,
      backgroundColor: Colors.transparent,
      panelMinSize: panelMinSize,
      panelMaxSize: panelMaxSize,
      panelWidth: of2.size.width,
      hideFooter: true,
      parallax: true,
      parallaxOffset: 0.015,
      // hidePanelHeader: false,
      footerController: footerController,
      controller: panelController,
      body: child,
      panel: PlayPage(),
      panelHeader: GestureDetector(
        child: SongInfoBar(),
        onTap: () => panelController.show(),
      ),
      footerHeight: showBottomBar ? 65 + of2.padding.bottom : 0,
      footer: showBottomBar
          ? BackdropView(
              decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(30.w)),
              child: Consumer(builder: (context, ref, child) {
                // 计算当前显示的 index：通过当前路由路径在 displayBottomItems 中查找
                final currentPath = GoRouter.of(context).location;
                int displayIndex =
                    displayBottomItems.indexWhere((e) => e.path == currentPath);
                if (displayIndex < 0) {
                  // 如果当前路径不是底部任一项，尝试使用 provider 保存的 index（兼容），
                  // 并将其映射到 display 列表（若 provider index 指向被删除的 home，我们需要降一位或找到对应 path）
                  final providerIndex = ref.watch(currentIndexProvider);
                  if (providerIndex >= 0 && providerIndex < AppConfig.bottomItems.length) {
                    final providerPath = AppConfig.bottomItems[providerIndex].path;
                    displayIndex = displayBottomItems.indexWhere((e) => e.path == providerPath);
                    if (displayIndex < 0) {
                      // fallback to first display item
                      displayIndex = 0;
                    }
                  } else {
                    displayIndex = 0;
                  }
                }

                return BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: displayIndex,
                  items: displayBottomItems.map((e) {
                    return BottomNavigationBarItem(
                        icon:
                            Padding(padding: EdgeInsets.only(bottom: 5.w), child: Icon(e.iconData)),
                        activeIcon: Padding(
                            padding: EdgeInsets.only(bottom: 5.w), child: Icon(e.activeIconData)),
                        label: e.title);
                  }).toList(),
                  onTap: (tappedDisplayIndex) {
                    // tappedDisplayIndex 是在 displayBottomItems 中的索引，
                    // 需要找到该项在原始 AppConfig.bottomItems 中对应的索引并更新 provider（保持全局索引一致）
                    final tappedPath = displayBottomItems[tappedDisplayIndex].path;
                    final originalIndex =
                        AppConfig.bottomItems.indexWhere((e) => e.path == tappedPath);
                    if (originalIndex >= 0) {
                      ref.read(currentIndexProvider.notifier).setIndex(originalIndex);
                    }
                    context.replace(tappedPath);
                  },
                );
              }))
          : null,
    );
  }
}

class DrawerWidget extends StatelessWidget {
  final Widget child;

  const DrawerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var controller = GetIt.I<ZoomDrawerController>();
    var of = MediaQuery.of(context);
    return ZoomDrawer(
        controller: controller,
        reverseDuration: Duration(milliseconds: 200),
        duration: Duration(milliseconds: 200),
        menuScreen: MenuPage(),
        menuScreenWidth: of.size.width,
        mainScreenScale: .18,
        angle: -8,
        slideWidth: 200.w,
        dragOffset: 200.w,
        shadowLayer1Color: Colors.grey.withAlpha(20),
        shadowLayer2Color: Colors.grey.withAlpha(30),
        showShadow: true,
        mainScreenTapClose: true,
        menuScreenTapClose: true,
        mainScreen: SliderWidget(showBottomBar: false, child: child));
  }
}

/// 全局播放条
class SongInfoBar extends ConsumerWidget {
  const SongInfoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItem = ref.watch(mediaItemProvider).value;
    bool isDark = ref.watch(themeModeNotifierProvider) == ThemeMode.dark;
    Color scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final color = ref.watch(mediaColorProvider).maybeWhen(
        data: (c) => ColorUtils.lightenColor(
            (isDark ? c.darkMutedColor?.color : c.dominantColor?.color) ?? scaffoldColor,
            isDark ? 0.2 : 0.8),
        orElse: () => scaffoldColor);
    return _AnimatedSongInfoBar(
      mediaItem: mediaItem,
      scaffoldColor: scaffoldColor,
      color: color,
    );
  }
}

class _AnimatedSongInfoBar extends StatelessWidget {
  final MediaItem? mediaItem;
  final Color scaffoldColor;
  final Color color;

  const _AnimatedSongInfoBar({
    required this.mediaItem,
    required this.scaffoldColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final baseHeight = 62.w;
    final baseImage = 42.w;

    // 静态缓存
    final cachedImage = CachedImage(
      imageUrl: mediaItem?.artUri.toString() ?? '',
      width: baseImage,
      height: baseImage,
      borderRadius: baseImage / 2,
    );

    final gradient = LinearGradient(colors: [color.withAlpha(160), scaffoldColor.withAlpha(160)]);

    final infoRow = SizedBox(
      height: baseHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 10.w),
          cachedImage,
          SizedBox(width: 10.w),
          Expanded(
              child: Text(
            mediaItem?.title ?? '',
            style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
            maxLines: 1,
          )),
          SizedBox(width: 18.w),
          TogglePlayButton(22.sp),
          ControlButton(
              image: HugeIconsStroke.next, onTap: () => BujuanMusicHandler().skipToNext()),
          SizedBox(width: 8.w),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: RepaintBoundary(
        child: BackdropView(
          blur: true,
          height: baseHeight,
          gradient: gradient,
          width: width,
          borderRadius: BorderRadius.circular(20.w),
          child: infoRow,
        ),
      ),
    );
  }
}

/// 控制播放暂停的按钮 指根据playing刷新ui
class TogglePlayButton extends ConsumerWidget {
  final double size;

  const TogglePlayButton(this.size, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var playing = ref.watch(playbackStateProvider.select((state) => state.value?.playing ?? false));
    return IconButton(
      onPressed: () => BujuanMusicHandler().playOrPause(),
      icon: Icon(
        playing ? HugeIconsStroke.pause : HugeIconsStroke.play,
        size: size,
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData image;
  final VoidCallback? onTap;
  final Color? color;

  const ControlButton({super.key, required this.image, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        image,
        size: 24.sp,
        color: color,
      ),
      onPressed: onTap,
    );
  }
}

class DynamicPadding extends ConsumerWidget {
  final bool hasBottom;

  const DynamicPadding({super.key, this.hasBottom = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool draw = ref.watch(homeStyleProvider) == HomeStyleType.draw;
    var of2 = MediaQuery.of(context);
    return SizedBox(
      height: draw || !hasBottom
          ? 60.w + of2.padding.bottom / (Platform.isAndroid ? 1 : 1.3)
          : 60.w + 65 + of2.padding.bottom,
    );
  }
}
