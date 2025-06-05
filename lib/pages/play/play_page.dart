import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/utils/time_utils.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:bujuan_music/widgets/slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../utils/color_utils.dart';
import '../../widgets/curved_progress_bar.dart';
import '../main/provider.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 缓存媒体查询结果
    var of = MediaQuery.of(context);
    double minHeightBox = 45.w + (of.padding.bottom == 0 ? 20.w : of.padding.bottom);
    double maxHeightBox = of.size.height - of.padding.top - 5.w;
    return SizedBox(
      width: of.size.width,
      height: maxHeightBox,
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
                    end: ColorUtils.lightenColor(color, .6).withAlpha(100),
                  ),
                  duration: Duration(milliseconds: 800),
                  builder: (context, animatedColor, _) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Theme.of(context).scaffoldBackgroundColor, animatedColor ?? Colors.transparent],
                            begin: Alignment.topLeft,
                            end: Alignment.topRight),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _MusicControlsSection(),
          Consumer(
              builder: (context, ref, child) => Positioned(
                    top: -minHeightBox * ref.watch(boxPanelDetailDataProvider),
                    child: GestureDetector(
                      child: SongInfoBar(),
                      onTap: () => GetIt.I<BoxController>().openBox(),
                    ),
                  )),
        ],
      ),
    );
  }
}

class SongInfoBar extends StatelessWidget {
  const SongInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width,
      child: Row(
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
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }),
          Spacer(),
          Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Consumer(
                  builder: (context, ref, child) => IconButton(
                      onPressed: () {
                        BujuanMusicHandler().playOrPause();
                      },
                      icon: Icon(
                        (ref.watch(playbackStateProvider).value?.playing ?? false)
                            ? HugeIcons.strokeRoundedPause
                            : HugeIcons.strokeRoundedPlay,
                        size: 24.w,
                      )))),
        ],
      ),
    );
  }
}

class _MusicControlsSection extends StatelessWidget {
  const _MusicControlsSection();

  @override
  Widget build(BuildContext context) {
    var of = MediaQuery.of(context);
    double minHeightBox = 45.w + (of.padding.bottom == 0 ? 20.w : of.padding.bottom);
    return Column(
      children: [
        Consumer(
            builder: (context, ref, child) => AnimatedContainer(
                  duration: Duration(milliseconds: 60),
                  height: (minHeightBox + (of.padding.bottom == 0 ? 20.w : of.padding.bottom)) * (1 - ref.watch(boxPanelDetailDataProvider)),
                )), SizedBox(
          height: 35.w,
          child: Transform(
            transform: Matrix4.translationValues(0, -15, 0),
            child: Icon(
              Icons.remove_rounded,
              color: Colors.grey.withAlpha(120),
              size: 62.w,
            ),
          ),
        ),
        Consumer(builder: (context, ref, child) {
          var watch = ref.watch(mediaItemProvider);
          return Column(
            children: [
              CachedImage(
                imageUrl: watch.value?.artUri.toString() ?? '',
                width: 310.w,
                height: 310.w,
                borderRadius: 25.w,
              ),
              SizedBox(height: 30.w),
              Text('${watch.value?.title}', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 5.w),
              Text('${watch.value?.artist}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Colors.grey)),
            ],
          );
        }),
        Expanded(child: _ProgressBarWithTime()),
        _PlaybackControls(),
        SizedBox(height: 80.w)
      ],
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
                  builder: (context, ref, child) {
                    PaletteColor color = ref.watch(mediaColorProvider).maybeWhen(
                      data: (c) => c.dominantColor!,
                      orElse: () => PaletteColor(Colors.green, 1),
                    );
                    final position = ref.watch(playbackStateProvider).value?.updatePosition.inSeconds ?? 0;
                    final duration = ref.watch(mediaItemProvider).value?.duration?.inSeconds ?? 0;

                    final progress = duration > 0 ? position / duration : 0.0;

                    return Column(
                      children: [
                        CurvedProgressBar(
                          progress: progress,
                          progressColor: ColorUtils.lightenColor(color.bodyTextColor,0.6),
                          activeProgressColor: ColorUtils.lightenColor(color.color,0.5),
                          onProgressChange: (value) => BujuanMusicHandler().seek(Duration(seconds: (duration*value).toInt())),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                TimeUtils.formatDuration(position),
                                style: _timeTextStyle),
                            Text(
                                TimeUtils.formatDuration(duration),
                                style: _timeTextStyle),
                          ],
                        ),
                      ],
                    );
                  })),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 15.w),
        _ControlButton(image: HugeIcons.strokeRoundedShuffle),
        SizedBox(width: 15.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ControlButton(image: HugeIcons.strokeRoundedPrevious,onTap: () => BujuanMusicHandler().skipToPrevious(),),
              _PlayPauseButton(),
              _ControlButton(image: HugeIcons.strokeRoundedNext,onTap: () => BujuanMusicHandler().skipToNext(),),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        _ControlButton(image: HugeIcons.strokeRoundedRepeatOne02),
        SizedBox(width: 15.w),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData image;
  final VoidCallback? onTap;

  const _ControlButton({required this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(image,size: 28.sp),
      onPressed: () => onTap?.call(),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          PaletteColor color = ref.watch(mediaColorProvider).maybeWhen(
            data: (c) => c.dominantColor!,
            orElse: () => PaletteColor(Colors.green, 1),
          );
          return Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
                color: ColorUtils.lightenColor(color.color,0.25),
                borderRadius: BorderRadius.circular(50.w)
            ),
            child: IconButton(
                onPressed: () {
                  BujuanMusicHandler().playOrPause();
                },
                icon: Icon(
                  (ref.watch(playbackStateProvider).value?.playing ?? false)
                      ? HugeIcons.strokeRoundedPause
                      : HugeIcons.strokeRoundedPlay,
                  color: color.titleTextColor,
                  size: 28.sp,
                )),
          );
        });
  }
}

const _timeTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.grey,
  fontWeight: FontWeight.w600,
);
