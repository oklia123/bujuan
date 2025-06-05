import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:bujuan_music/widgets/slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import '../../common/values/app_images.dart';
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
    return SizedBox(
      width: of.size.width,
      height: of.size.height,
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
                    end: ColorUtils.lightenColor(color, .8).withAlpha(100),
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
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 28.w,
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
              Text('${watch.value?.title}', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 5.w),
              Text('${watch.value?.artist}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
            ],
          );
        }),
        SizedBox(height: 30.w),
        _ProgressBarWithTime(),
        SizedBox(height: 30.w),
        _PlaybackControls(),
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
        SizedBox(width: 30.w),
        _ControlButton(image: AppImages.shuffle),
        SizedBox(width: 15.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ControlButton(image: AppImages.left,onTap: () => BujuanMusicHandler().skipToPrevious(),),
              _PlayPauseButton(),
              _ControlButton(image: AppImages.right,onTap: () => BujuanMusicHandler().skipToNext(),),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        _ControlButton(image: AppImages.cycle),
        SizedBox(width: 30.w),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String image;
  final VoidCallback? onTap;

  const _ControlButton({required this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Image.asset(image, width: 24.w, height: 24.w),
      onTap: () => onTap?.call(),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) => IconButton(
            onPressed: () {
              BujuanMusicHandler().playOrPause();
            },
            icon: Icon(
              (ref.watch(playbackStateProvider).value?.playing ?? false)
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 36.sp,
            )));
  }
}

const _timeTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.grey,
  fontWeight: FontWeight.w600,
);
