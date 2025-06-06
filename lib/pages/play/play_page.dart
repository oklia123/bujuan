import 'dart:ui';

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

class PlayPage extends ConsumerWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final minHeightBox = 45.w + (mediaQuery.padding.bottom == 0 ? 20.w : mediaQuery.padding.bottom);
    final maxHeightBox = mediaQuery.size.height - mediaQuery.padding.top - 5.w;

    final color = ref.watch(mediaColorProvider).maybeWhen(
          data: (c) => c.dominantColor?.color ?? Colors.transparent,
          orElse: () => Colors.transparent,
        );

    return SizedBox(
      width: mediaQuery.size.width,
      height: maxHeightBox,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: AnimatedGradientBackground(
              startColor: Theme.of(context).scaffoldBackgroundColor,
              endColor: ColorUtils.lightenColor(color, .6).withAlpha(100),
            ),
          ),
          const _MusicControlsSection(),
          Positioned(
            top: -minHeightBox * ref.watch(boxPanelDetailDataProvider),
            child: GestureDetector(
              child: const SongInfoBar(),
              onTap: () => GetIt.I<BoxController>().openBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedGradientBackground extends StatelessWidget {
  final Color startColor;
  final Color endColor;

  const AnimatedGradientBackground({super.key, required this.startColor, required this.endColor});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: startColor, end: endColor),
      duration: const Duration(milliseconds: 500),
      builder: (context, color, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, color ?? Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
      ),
    );
  }
}

class CoverBackground extends ConsumerWidget {
  const CoverBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var watch = ref.watch(mediaItemProvider);
    return Stack(
      children: [
        CachedImage(
          imageUrl: watch.value?.artUri.toString() ?? '',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // sigma 越大模糊越强
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ],
    );
  }
}

class SongInfoBar extends ConsumerWidget {
  const SongInfoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItem = ref.watch(mediaItemProvider).value;

    return Container(
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 30.w),
            child: SizedBox(
              height: 60.w,
              child: Row(
                children: [
                  CachedImage(
                    imageUrl: mediaItem?.artUri.toString() ?? '',
                    width: 40.w,
                    height: 40.w,
                    borderRadius: 20.w,
                  ),
                  SizedBox(width: 10.w),
                  Text(mediaItem?.title ?? 'Bujuan',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              onPressed: () => BujuanMusicHandler().playOrPause(),
              icon: Icon(
                ref.watch(playbackStateProvider).value?.playing == true
                    ? HugeIcons.strokeRoundedPause
                    : HugeIcons.strokeRoundedPlay,
                size: 24.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicControlsSection extends ConsumerWidget {
  const _MusicControlsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final minHeightBox =
        45.w + (mediaQuery.padding.bottom == 0 ? 20.w : mediaQuery.padding.bottom) * 2;
    final mediaItem = ref.watch(mediaItemProvider).value;

    return Column(
      children: [
        AnimatedContainer(
          duration: Duration.zero,
          height: minHeightBox * (1 - ref.watch(boxPanelDetailDataProvider)),
        ),
        SizedBox(
          height: 35.w,
          child: Transform(
            transform: Matrix4.translationValues(0, -15, 0),
            child: Icon(Icons.remove_rounded, color: Colors.grey.withAlpha(120), size: 62.w),
          ),
        ),
        SizedBox(height: 10.w),
        Column(
          children: [
            CachedImage(
              imageUrl: mediaItem?.artUri.toString() ?? '',
              width: 290.w,
              height: 290.w,
              borderRadius: 25.w,
              pWidth: 600,
              pHeight: 600,
            ),
            SizedBox(height: 20.w),
            Text(mediaItem?.title ?? '',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500)),
            SizedBox(height: 3.w),
            Text(mediaItem?.artist ?? '',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Colors.grey)),
          ],
        ),
        Expanded(child: _ProgressBarWithTime()),
        const _PlaybackControls(),
        SizedBox(height: 80.w),
      ],
    );
  }
}

class Sleep extends ConsumerWidget {
  const Sleep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(mediaColorProvider).maybeWhen(
          data: (c) => c.dominantColor!,
          orElse: () => PaletteColor(Colors.white, 1),
        );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.w),
      padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 25.w),
      decoration: BoxDecoration(color: ColorUtils.lightenColor(color.color, 0.7),borderRadius: BorderRadius.circular(30.w)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedAlarmClock,
                size: 16.sp,
              ),
              Text('21:36')
            ],
          ),
          Text('1.2x'),
          Icon(
            HugeIcons.strokeRoundedMenu04,
            size: 16.sp,
          ),
        ],
      ),
    );
  }
}

class _ProgressBarWithTime extends ConsumerWidget {
  const _ProgressBarWithTime();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(mediaColorProvider).maybeWhen(
          data: (c) => c.dominantColor!,
          orElse: () => PaletteColor(Colors.green, 1),
        );
    final position = ref.watch(playbackStateProvider).value?.updatePosition.inSeconds ?? 0;
    final duration = ref.watch(mediaItemProvider).value?.duration?.inSeconds ?? 0;
    final progress = duration > 0 ? position / duration : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IgnoreDraggableWidget(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 80),
              builder: (context, value, _) => CurvedProgressBar(
                progress: value,
                progressColor: ColorUtils.lightenColor(color.color, 0.6),
                activeProgressColor: ColorUtils.lightenColor(color.color, 0.2),
                onProgressChange: (value) =>
                    BujuanMusicHandler().seek(Duration(seconds: (duration * value).toInt())),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TimeUtils.formatDuration(position), style: _timeTextStyle),
              Text(TimeUtils.formatDuration(duration), style: _timeTextStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 15.w),
        const _ControlButton(image: HugeIcons.strokeRoundedShuffle),
        SizedBox(width: 15.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ControlButton(
                image: HugeIcons.strokeRoundedPrevious,
                onTap: () => BujuanMusicHandler().skipToPrevious(),
              ),
              const _PlayPauseButton(),
              _ControlButton(
                image: HugeIcons.strokeRoundedNext,
                onTap: () => BujuanMusicHandler().skipToNext(),
              ),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        const _ControlButton(image: HugeIcons.strokeRoundedRepeatOne02),
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
      icon: Icon(
        image,
        size: 24.sp,
        color: Colors.black,
      ),
      onPressed: onTap,
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(mediaColorProvider).maybeWhen(
          data: (c) => c.dominantColor!,
          orElse: () => PaletteColor(Colors.white, 1),
        );

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.color,
        borderRadius: BorderRadius.circular(50.w),
      ),
      child: IconButton(
        onPressed: () => BujuanMusicHandler().playOrPause(),
        icon: Icon(
          ref.watch(playbackStateProvider).value?.playing == true
              ? HugeIcons.strokeRoundedPause
              : HugeIcons.strokeRoundedPlay,
          color: color.titleTextColor,
          size: 24.sp,
        ),
      ),
    );
  }
}

const _timeTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.grey,
  fontWeight: FontWeight.w600,
);
