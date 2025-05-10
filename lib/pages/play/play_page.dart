import 'dart:ui';
import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import '../../common/values/app_images.dart';
import '../../utils/color_utils.dart';
import '../../widgets/curved_progress_bar.dart';
import '../../widgets/slide.dart';
import '../main/provider.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 缓存媒体查询结果
    final mediaQuery = MediaQuery.of(context);
    return SizedBox(
      width: mediaQuery.size.width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, child) {
                final color = ref.watch(mediaColorProvider).maybeWhen(
                      data: (c) => c.dominantColor?.color ?? Colors.green,
                      orElse: () => Colors.transparent,
                    );
                return TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: Colors.transparent,
                    end: ColorUtils.lightenColor(color, .3).withAlpha(60),
                  ),
                  duration: Duration(milliseconds: 800),
                  builder: (context, animatedColor, _) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.transparent, animatedColor ?? Colors.transparent],
                            begin: Alignment.topLeft,
                            end: Alignment.topRight),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [aa()],
          )
          // InkWell(
          //   onTap: GetIt.I<BoxController>().openBox,
          //   child: Column(
          //     children: [SongInfoBar(), SizedBox(height: 80.w), _ProgressBarWithTime()],
          //   ),
          // ),
          // Container(
          //   margin: EdgeInsets.only(top: 6.w),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).iconTheme.color!.withAlpha(130),
          //     borderRadius: BorderRadius.circular(3.w)
          //   ),
          //   width: 28.w,
          //   height: 5.w,
          // ),
        ],
      ),
    );
  }

  Widget aa() {
    final result = Consumer(
        builder: (context, ref, child) => CachedImage(
              imageUrl: ref.watch(mediaItemProvider).value?.artUri.toString() ?? '',
              width: 300.w,
              height: 300.w,borderRadius: 150.w,
            ));

    final animation = SheetOffsetDrivenAnimation(
      controller: GetIt.I<SheetController>(),
      initialValue: 0,
      startOffset: null,
      endOffset: null,
    ).drive(Tween<double>(begin: 1.0, end: 0.0));

    // Hide the button when the sheet is dragged down.
    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: result,
      ),
    );
  }
}

class SongInfoBar extends StatelessWidget {
  const SongInfoBar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Consumer(builder: (context, ref, child) {
          var watch = ref.watch(mediaItemProvider);
          return Padding(
            padding: EdgeInsets.only(left: 20, right: 30.w),
            child: SizedBox(
              height: 60.w,
              child: Row(
                children: [
                  CachedImage(
                    imageUrl: watch.value?.artUri.toString() ?? '',
                    width: 40.w,
                    height: 40.w,
                    borderRadius: 20.w,
                  ),
                  SizedBox(width: 10.w),
                  Text(watch.value?.title ?? 'Bujuan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          );
        }),
        Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Consumer(
                builder: (context, ref, child) => IconButton(
                    onPressed: () {
                      BujuanMusicHandler().playOrPause();
                    },
                    icon: Icon(
                      (ref.watch(playbackStateProvider).value?.playing ?? false)
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 28.w,
                    )))),
      ],
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IgnoreDraggableWidget(
              child: Consumer(
                  builder: (context, ref, child) => Column(
                        children: [
                          CurvedProgressBar(
                            progress: 0,
                            progressColor: Colors.grey.withOpacity(.5),
                            activeProgressColor: Colors.black.withOpacity(.6),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${ref.watch(playbackStateProvider).value?.updatePosition.inSeconds}',
                                  style: _timeTextStyle),
                              Text(
                                  '${ref.watch(mediaItemProvider).value?.duration?.inSeconds ?? 0}',
                                  style: _timeTextStyle),
                            ],
                          ),
                        ],
                      ))),
        ],
      ),
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
