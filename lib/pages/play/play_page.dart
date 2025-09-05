import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/widgets/backdrop.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../utils/color_utils.dart';
import '../../widgets/wave.dart';
import '../main/provider.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropView(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(190), // 半透明背景
        borderRadius: BorderRadius.circular(30.w),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: const _MusicControlsSection(),
    );
  }
}

class SongInfoBar extends ConsumerWidget {
  const SongInfoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItem = ref.watch(mediaItemProvider).value;
    bool isDark = ref.read(themeModeNotifierProvider) == ThemeMode.dark;
    Color scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final color = ref.watch(mediaColorProvider).maybeWhen(
        data: (c) => (isDark ? c.darkMutedColor?.color : c.dominantColor?.color) ?? scaffoldColor,
        orElse: () => scaffoldColor);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: BackdropView(
        gradient: LinearGradient(colors: [
          ColorUtils.lightenColor(color, isDark ? 0.2 : 0.8).withAlpha(200),
          scaffoldColor.withAlpha(120)
        ]),
        width: MediaQuery.of(context).size.width - 16.w,
        borderRadius: BorderRadius.circular(20.w),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
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
                  ],
                ),
              ),
            ),
            Expanded(
                child: Text(
              mediaItem?.title ?? 'Bujuan',
              style: TextStyle(
                  fontSize: 16.sp, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
              maxLines: 1,
            )),
            TogglePlayButton(22.w),
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: IconButton(
                onPressed: () => BujuanMusicHandler().skipToNext(),
                icon: Icon(
                  HugeIconsStroke.next,
                  size: 22.w,
                ),
              ),
            )
          ],
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

class _MusicControlsSection extends StatelessWidget {
  const _MusicControlsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 35.w,
          child: Transform(
            transform: Matrix4.translationValues(0, -15, 0),
            child: Icon(Icons.remove_rounded, color: Colors.grey.withAlpha(120), size: 62.w),
          ),
        ),
        SizedBox(height: 10.w),
        Consumer(builder: (context, ref, child) {
          final mediaItem = ref.watch(mediaItemProvider).value;
          return Column(
            children: [
              CachedImage(
                imageUrl: mediaItem?.artUri.toString() ?? '',
                width: 300.w,
                height: 300.w,
                borderRadius: 150.w,
                pWidth: 600,
                pHeight: 600,
              ),
              SizedBox(height: 20.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  mediaItem?.title ?? '',
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),
                  maxLines: 1,
                ),
              ),
              SizedBox(height: 5.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  mediaItem?.artist ?? '',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                  maxLines: 1,
                ),
              ),
            ],
          );
        }),
        Expanded(
            child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            height: 35.w,
            child: MusicProgressBar(),
          ),
        )),
        const _PlaybackControls(),
        SizedBox(height: 80.w),
      ],
    );
  }
}

/// 音乐进度条
class MusicProgressBar extends ConsumerWidget {
  const MusicProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(
        playbackStateProvider.select((state) => state.value?.updatePosition ?? Duration.zero));
    final mediaItem = ref.watch(mediaItemProvider).value;
    final position = playbackState.inMilliseconds;
    final duration = mediaItem?.duration?.inMilliseconds ?? 0;
    final progress = (duration > 0) ? position / duration : 0.0;
    var color = Theme.of(context).iconTheme.color ?? Colors.white;
    return RepaintBoundary(
      child: WaveformProgressWidget(
        progress: progress,
        min: 0,
        max: 1,
        playedColor: color.withAlpha(150),
        unplayedColor: color.withAlpha(100),
        // thumbColor: Colors.transparent,
        onChangeEnd: (value) {
          final seekTo = Duration(milliseconds: (duration * value).toInt());
          BujuanMusicHandler().seek(seekTo);
        },
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
        const _ControlButton(
          image: HugeIconsSolid.favourite,
          color: Colors.red,
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ControlButton(
                image: HugeIconsStroke.previous,
                onTap: () => BujuanMusicHandler().skipToPrevious(),
              ),
              const _PlayPauseButton(),
              _ControlButton(
                image: HugeIconsStroke.next,
                onTap: () => BujuanMusicHandler().skipToNext(),
              ),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        Consumer(builder: (context, ref, child) {
          var loopMode = ref.watch(loopModeNotifierProvider);
          return _ControlButton(
            image: loopMode == LoopMode.one
                ? HugeIconsStroke.repeatOne02
                : loopMode == LoopMode.playlist
                    ? HugeIconsStroke.repeat
                    : HugeIconsStroke.shuffle,
            onTap: () {
              ref.read(loopModeNotifierProvider.notifier).changeMode();
            },
          );
        }),
        SizedBox(width: 15.w),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData image;
  final VoidCallback? onTap;
  final Color? color;

  const _ControlButton({required this.image, this.onTap, this.color});

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
        color: color.color.withAlpha(160),
        borderRadius: BorderRadius.circular(50.w),
      ),
      child: IconButton(
        onPressed: () {
          BujuanMusicHandler().playOrPause();
        },
        icon: Icon(
          ref.watch(playbackStateProvider).value?.playing == true
              ? HugeIconsStroke.pause
              : HugeIconsStroke.play,
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

///液体
