import 'dart:ui';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/values/app_images.dart';
import '../../widgets/curved_progress_bar.dart';
import '../../widgets/slide.dart';
import '../main/provider.dart';

class PlayPage extends StatelessWidget {
  final BoxController boxController;

  const PlayPage({super.key, required this.boxController});

  @override
  Widget build(BuildContext context) {
    // 缓存媒体查询结果
    final mediaQuery = MediaQuery.of(context);
    return SizedBox(
      height: mediaQuery.size.height - mediaQuery.padding.top - 10.w,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // 控制模糊程度
              child: Container(
                decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [Colors.transparent, Colors.green.withAlpha(40)])),
              ),
            ),
          ),
          GestureDetector(
            onTap: boxController.openBox,
            child: _SongInfoBar(),
          )
        ],
      ),
    );
  }
}

class _SongInfoBar extends StatelessWidget {
  const _SongInfoBar();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return ref.watch(mediaItemProvider).when(
          data: (mediaItem) => Padding(
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
                      Spacer(),
                      Icon(Icons.play_arrow),
                    ],
                  ),
                ),
              ),
          error: (_, __) => SizedBox(),
          loading: () => SizedBox());
    });
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
