import 'package:bujuan_music/pages/main/menu_page.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../widgets/slide.dart';

class MainPage extends StatelessWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var of = MediaQuery.of(context);
    double minHeightBox = 45.w + of.padding.bottom;
    double maxHeightBox = of.size.height - of.padding.top - 5.w;
    return Scaffold(
      body: ZoomDrawer(
          controller: GetIt.I<ZoomDrawerController>(),
          reverseDuration: Duration(milliseconds: 1000),
          menuScreen: MenuPage(),
          menuScreenWidth: MediaQuery.of(context).size.width,
          mainScreenScale: .18,
          angle: -8,
          slideWidth: 200.w,
          dragOffset: 200.w,
          shadowLayer1Color: Colors.grey.withAlpha(20),
          shadowLayer2Color: Colors.grey.withAlpha(30),
          showShadow: true,
          mainScreenTapClose: true,
          menuScreenTapClose: true,
          mainScreen: Consumer(builder: (context, ref, c) {
            return SlidingBox(
              controller: GetIt.I<BoxController>(),
              collapsed: true,
              minHeight: minHeightBox,
              maxHeight: maxHeightBox,
              color: Theme.of(context).scaffoldBackgroundColor,
              style: BoxStyle.none,
              draggableIconVisible: false,
              draggableIconBackColor: Colors.white,
              onBoxSlide: (value) =>
                  ref.read(boxPanelDetailDataProvider.notifier).updatePanelDetail(value),
              backdrop: Backdrop(
                color: Theme.of(context).scaffoldBackgroundColor,
                body: Padding(
                  padding: EdgeInsets.only(top: 90.w),
                  child: child,
                ),
                appBar: BackdropAppBar(
                    leading: Icon(
                      HugeIcons.strokeRoundedInbox,
                      size: 26.sp,
                    ),
                    title: Text(
                      'Bujuan',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            HugeIcons.strokeRoundedSearch01,
                            size: 24.sp,
                          )),
                    ]),
              ),
              bodyBuilder: (s, _) => GestureDetector(
                child: PlayPage(),
                onHorizontalDragUpdate: (e) {},
              ),
            );
          })),
    );
  }
}

class StreamWidget extends StatelessWidget {
  const StreamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// class MainPage extends StatefulWidget {
//   final Widget child;
//
//   const MainPage({super.key, required this.child});
//
//   @override
//   State<MainPage> createState() => _MainPageState();
// }
//
// class _MainPageState extends State<MainPage> {
//   BujuanMusicHandler bujuanMusicHandler = GetIt.I<BujuanMusicHandler>();
//   List<MediaItem> items = [];
//   @override
//   void initState() {
//     // BujuanMusicManager().sendSmsCode(phone: '13223087330');
//     // BujuanMusicManager().loginCellPhone(phone: '13223087330',captcha: '5123');
//
//     bujuanMusicHandler.playbackState.stream.listen((playState) {
//
//     });
//     bujuanMusicHandler.queue.stream.listen((queue) {
//       log('-----------------播放列表\n${queue.map((e) => e.title).toList().join('\n')}');
//     });
//     getNewSong();
//     super.initState();
//   }
//
//   getNewSong() async {
//     var newSongs = await BujuanMusicManager().newSongs();
//     if (newSongs != null) {
//       var songs = newSongs.data ?? [];
//        items..clear()..addAll(songs
//            .map((e) => MediaItem(
//            id: '${e.id}',
//            title: e.name ?? "",
//            duration: Duration(milliseconds: e.duration ?? 0),
//            artist: (e.artists??[]).map((e) => e.name).toList().join(' '),
//            artUri: Uri.parse(e.album?.picUrl ?? '')))
//            .toList()) ;
//        setState(() {
//
//        });
//       bujuanMusicHandler.updateQueue(items);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Column(
//         children: [
//           Expanded(child: ListView.builder(itemBuilder: (c,i) => ListTile(
//             title: Text(items[i].title),
//             subtitle: Text(items[i].id),
//           ),itemCount: items.length,)),
//           Row(
//             children: [
//               TextButton(
//                   onPressed: () {
//                     bujuanMusicHandler.skipToPrevious();
//                   },
//                   child: Text('上一首')),
//               TextButton(
//                   onPressed: () {
//                     bujuanMusicHandler.playOrPause();
//                   },
//                   child: Text('play')),
//               TextButton(
//                   onPressed: () {
//                     bujuanMusicHandler.addQueueItem(items[0]);
//                   },
//                   child: Text('下一首')),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
