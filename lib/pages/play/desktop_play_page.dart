import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DesktopPlayPage extends StatelessWidget {
  const DesktopPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => context.pop(), icon: Icon(HugeIcons.strokeRoundedCancel01)),
        title: Text('Now Playing'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(15.w),
        child: Row(
          children: [
            PlayInfoView(),
          ],
        ),
      ),
    );
  }
}

class PlayInfoView extends ConsumerWidget {
  const PlayInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var media = ref.watch(mediaItemProvider).value;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CachedImage(
          imageUrl: media?.artUri.toString() ?? '',
          width: 260.w,
          height: 260.w,
          pWidth: 600,
          pHeight: 600,
          borderRadius: 30.w,
        ),
      ],
    );
  }
}
