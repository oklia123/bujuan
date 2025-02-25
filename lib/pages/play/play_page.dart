import 'dart:ui';
import 'package:bujuan_music/pages/play/provider.dart';
import 'package:bujuan_music/widgets/pa.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/values/app_images.dart';
import '../../widgets/curved_progress_bar.dart';
import '../main/provider.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return Container();
    // 缓存媒体查询结果
    final mediaQuery = MediaQuery.of(context);
    final double top = mediaQuery.padding.top;
    final double bottom = mediaQuery.padding.bottom;

    return Stack(
      children: [
        // 使用const优化静态粒子效果组件
        // Consumer(builder: (context, ref, child) {
        //   var watch = ref.watch(getImageColorProvider(CachedNetworkImageProvider(
        //       'http://p1.music.126.net/gN6htv5E9WwyOoTASMuvDQ==/109951170483576228.jpg')));
        //   if (watch.hasValue) {
        //     return Particles(
        //       color: watch.value?.lightVibrantColor?.color ?? Colors.red,
        //       quantity: 100,
        //       ease: 80,
        //       vx: -.2,
        //       vy: -.4,
        //     );
        //   }
        //   return SizedBox.shrink();
        // }),
        Column(
          children: [
            // 使用Selector优化局部刷新
            _AnimatedCoverSection(top: top),
            SizedBox(height: 15.h),
            Expanded(
              child: _MusicControlsSection(bottom: bottom),
            ),
          ],
        )
      ],
    );
  }
}

class _AnimatedCoverSection extends ConsumerWidget {
  final double top;

  const _AnimatedCoverSection({required this.top});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelValue = ref.watch(slidingPanelDetailDataProvider);
    final panelController = ref.read(panelControllerProvider);
    return GestureDetector(
      onTap: panelController.open,
      child: Container(
        color: Colors.transparent,
        height: 350.w + top,
        child: Stack(
          children: [
            if (panelValue < 0.1) _SongInfoBar(),
            _AnimatedAlbumCover(panelValue: panelValue, top: top),
            _TopControlBar(panelValue: panelValue, top: top),
          ],
        ),
      ),
    );
  }
}

class _AnimatedAlbumCover extends StatelessWidget {
  final double panelValue;
  final double top;

  const _AnimatedAlbumCover({required this.panelValue, required this.top});

  @override
  Widget build(BuildContext context) {
    final imageSize = lerpDouble(45.w, 290.w, panelValue)!;
    final leftOffset = 10.w + panelValue * (375.w - 10.w - 290.w) / 2;
    final topOffset = 7.5.w + panelValue * (60.w - 7.5.w + top);

    return Positioned(
      left: leftOffset,
      top: topOffset,
      child: _AlbumCover(imageSize: imageSize),
    );
  }
}

class _AlbumCover extends StatelessWidget {
  final double imageSize;

  const _AlbumCover({required this.imageSize});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      width: imageSize,
      height: imageSize,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            "http://p1.music.126.net/gN6htv5E9WwyOoTASMuvDQ==/109951170483576228.jpg",
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _TopControlBar extends StatelessWidget {
  final double panelValue;
  final double top;

  const _TopControlBar({required this.panelValue, required this.top});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -60.w * (1 - panelValue) + top * panelValue,
      child: SizedBox(
        width: 375.w,
        height: 60.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.keyboard_arrow_down_outlined, size: 26),
              Icon(Icons.more_horiz, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongInfoBar extends StatelessWidget {
  const _SongInfoBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 70.w, right: 50.w),
      child: SizedBox(
        height: 60.w,
        child: Row(
          children: [
            Text('Lucky Strike',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
            Spacer(),
            Icon(Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}

class _MusicControlsSection extends StatelessWidget {
  final double bottom;

  const _MusicControlsSection({required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          const Text('Lucky Strike', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          const Text('Troy Sivan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(child: _ProgressBarWithTime()),
                const SizedBox(height: 4),
                _PlaybackControls(),
                SizedBox(height: 40.h + bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBarWithTime extends StatelessWidget {
  const _ProgressBarWithTime();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IgnoreDraggableWidget(
            child: CurvedProgressBar(
          progress: .4,
          progressColor: Colors.grey.withOpacity(.5),
          activeProgressColor: Colors.blueAccent.withOpacity(.5),
        )),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('01:24', style: _timeTextStyle),
            Text('04:27', style: _timeTextStyle),
          ],
        ),
      ],
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ControlButton(image: AppImages.shuffle),
        SizedBox(width: 15.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ControlButton(image: AppImages.left),
              _PlayPauseButton(),
              _ControlButton(image: AppImages.right),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        _ControlButton(image: AppImages.cycle),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String image;

  const _ControlButton({required this.image});

  @override
  Widget build(BuildContext context) {
    return Image.asset(image, width: 24.w, height: 24.w);
  }
}

class _PlayPauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(.5),
        borderRadius: BorderRadius.circular(23.w),
      ),
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
    );
  }
}

const _timeTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.grey,
  fontWeight: FontWeight.w600,
);
