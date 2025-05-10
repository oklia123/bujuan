import 'package:bujuan_music/pages/main/menu_page.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:faker/faker.dart' hide Image, Color;
import 'package:smooth_sheets/smooth_sheets.dart';
import '../../common/bujuan_music_handler.dart';
import '../../widgets/slide.dart';

// class MainPage extends StatelessWidget {
//   final Widget child;
//
//   const MainPage({super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     var of = MediaQuery.of(context);
//     double minHeightBox = 45.w + of.padding.bottom ;
//     double maxHeightBox = of.size.height - of.padding.top - 5.w;
//     return Scaffold(
//       body: ZoomDrawer(
//           controller: GetIt.I<ZoomDrawerController>(),
//           reverseDuration: Duration(milliseconds: 1000),
//           menuScreen: MenuPage(),
//           menuScreenWidth: MediaQuery.of(context).size.width,
//           mainScreenScale: .18,
//           angle: -8,
//           slideWidth: 200.w,
//           dragOffset: 200.w,
//           shadowLayer1Color: Colors.grey.withAlpha(20),
//           shadowLayer2Color: Colors.grey.withAlpha(30),
//           showShadow: true,
//           mainScreenTapClose: true,
//           menuScreenTapClose: true,
//           mainScreen: Consumer(builder: (context, ref, c) {
//             return SlidingBox(
//               controller: GetIt.I<BoxController>(),
//               collapsed: true,
//               minHeight: minHeightBox,
//               maxHeight: maxHeightBox,
//               color: Theme.of(context).scaffoldBackgroundColor,
//               style: BoxStyle.none,
//               draggableIconVisible: false,
//               draggableIconBackColor: Colors.white,
//               onBoxSlide: (value) =>
//                   ref.read(boxPanelDetailDataProvider.notifier).updatePanelDetail(value),
//               backdrop: Backdrop(
//                 moving: false,
//                 color: Theme.of(context).scaffoldBackgroundColor,
//                 body: Padding(
//                   padding: EdgeInsets.only(top: 90.w),
//                   child: child,
//                 ),
//                 appBar: BackdropAppBar(
//                     leading: Icon(
//                       HugeIcons.strokeRoundedInbox,
//                       size: 26.sp,
//                     ),
//                     title: Text(
//                       'Bujuan',
//                       style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//                     ),
//                     actions: [
//                       IconButton(
//                           onPressed: () {},
//                           icon: Icon(
//                             HugeIcons.strokeRoundedSearch01,
//                             size: 24.sp,
//                           )),
//                     ]),
//               ),
//               bodyBuilder: (s, _) => GestureDetector(
//                 child: PlayPage(),
//                 onHorizontalDragUpdate: (e) {},
//               ),
//             );
//           })),
//     );
//   }
// }
//
// class StreamWidget extends StatelessWidget {
//   const StreamWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

class MainPage extends StatelessWidget {
  final Widget child;

  const MainPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final systemUiInsets = MediaQuery.of(context).padding;

    final result = Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GestureDetector(
            child: PlayPage(),
            onHorizontalDragUpdate: (e){},
          ),
          _ContentSheet(
            systemUiInsets: systemUiInsets,
            child: child,
          ),
        ],
      ),
      // bottomNavigationBar: const _BottomNavigationBar(),
      floatingActionButton: const _MapButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

    return ZoomDrawer(
      controller: GetIt.I<ZoomDrawerController>(),
      reverseDuration: Duration(milliseconds: 1000),
      menuScreenWidth: MediaQuery.of(context).size.width,
      mainScreenScale: .18,
      menuBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      angle: -8,
      slideWidth: 200.w,
      dragOffset: 200.w,
      shadowLayer1Color: Colors.grey.withAlpha(20),
      shadowLayer2Color: Colors.grey.withAlpha(30),
      showShadow: true,
      mainScreenTapClose: true,
      menuScreenTapClose: true,
      menuScreen: MenuPage(),
      mainScreen: result,
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton();

  @override
  Widget build(BuildContext context) {
    final sheetController = GetIt.I<SheetController>();

    void onPressed() {
      if (sheetController.metrics case final it?) {
        // Collapse the sheet to reveal the map behind.
        sheetController.animateTo(SheetOffset.absolute(it.minOffset),
            curve: Curves.fastOutSlowIn, duration: Duration(milliseconds: 800));
      }
    }

    final result = GestureDetector(
      child: Consumer(
          builder: (context, ref, child) => GestureDetector(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Card(
                  elevation: 5,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.w)
                  ),
                  margin: EdgeInsets.all(0),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    child: CachedImage(
                      imageUrl: ref.watch(mediaItemProvider).value?.artUri.toString() ?? '',
                      width: 42.w,
                      height: 42.w,
                      borderRadius: 30.w,
                    ),
                  ),
                ),
                SizedBox(width: 5.w,),
                Card(
                  elevation: 5,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.w)
                  ),
                  margin: EdgeInsets.all(0),
                  child:  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    height: 45.w,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(ref.watch(mediaItemProvider).value?.title??'BuJuan',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14.sp),),
                        SizedBox(width: 8.w,),
                        GestureDetector(
                            onTap: () {
                              BujuanMusicHandler().playOrPause();
                            },
                            child: Icon(
                              (ref.watch(playbackStateProvider).value?.playing ?? false)
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 26.w,
                            ))
                      ],
                    ),
                  ),
                ),

              ],
            ),
          )),
      onTap: () => onPressed(),
    );

    final animation = SheetOffsetDrivenAnimation(
      controller: GetIt.I<SheetController>(),
      initialValue: 1,
      startOffset: null,
      endOffset: null,
    ).drive(CurveTween(curve: Curves.easeInExpo));

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

class _Map extends StatelessWidget {
  const _Map();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox.expand(
        child: Image.asset(
          'assets/fake_map.png',
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

class _ContentSheet extends StatelessWidget {
  final Widget child;

  const _ContentSheet({
    required this.systemUiInsets,
    required this.child,
  });

  final EdgeInsets systemUiInsets;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentHeight = constraints.maxHeight;
        final appbarHeight = MediaQuery.of(context).padding.top;
        final handleHeight =  _ContentSheetHandle(systemUiInsets).preferredSize.height;
        final sheetHeight = parentHeight - appbarHeight + handleHeight;
        final minSheetOffset = SheetOffset.absolute(handleHeight);

        return SheetViewport(
          child: Sheet(
            scrollConfiguration: const SheetScrollConfiguration(),
            controller: GetIt.I<SheetController>(),
            snapGrid: SheetSnapGrid(
              snaps: [minSheetOffset, const SheetOffset(1)],
            ),
            decoration:  MaterialSheetDecoration(
              size: SheetSize.fit,
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            child: SizedBox(
              height: sheetHeight,
              child: Column(
                children: [
                  _ContentSheetHandle(systemUiInsets),
                  Expanded(
                      child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: child,
                      )
                    ],
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContentSheetHandle extends StatelessWidget implements PreferredSizeWidget {
  final EdgeInsets systemUiInsets;
  const _ContentSheetHandle(this.systemUiInsets);

  @override
  Size get preferredSize => Size.fromHeight(systemUiInsets.top+40.w);

  @override
  Widget build(BuildContext context) {
    final animation = SheetOffsetDrivenAnimation(
      controller: GetIt.I<SheetController>(),
      initialValue: 0,
      startOffset: null,
      endOffset: null,
    );

    // Hide the button when the sheet is dragged down.
    return SizedBox.fromSize(
      size: preferredSize,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          FadeTransition(
            opacity: animation,
            child: AppBar(leading: Icon(HugeIcons.strokeRoundedAbacus),title: Text('BuJuan',style: TextStyle(
                color: Colors.red
            ),),actions: [
              IconButton(onPressed: (){}, icon: Icon(HugeIcons.strokeRoundedSearch01))
            ],),
          ),
          FadeTransition(
            opacity: animation.drive(Tween<double>(begin: 1.0, end: 0.0)),
            child: GestureDetector(
              child: Center(
                child: Text('Back'),
              ),
              onTap: (){
                final sheetController = GetIt.I<SheetController>();
                if (sheetController.metrics case final it?) {
                  // Collapse the sheet to reveal the map behind.
                  sheetController.animateTo(SheetOffset.absolute(it.maxOffset),
                      curve: Curves.fastOutSlowIn, duration: Duration(milliseconds: 800));
                }
              },
            ),
          ),
          buildIndicator(context),
        ],
      ),
    );
  }

  Widget buildIndicator(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.w),
      height: 6,
      width: 40,
      decoration: const ShapeDecoration(
        color: Colors.black12,
        shape: StadiumBorder(),
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    final result = BottomNavigationBar(
      unselectedItemColor: Colors.black54,
      selectedItemColor: Colors.pink,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_outlined),
          label: 'Wishlists',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.luggage_outlined),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inbox_outlined),
          label: 'Inbox',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );

    // Hide the navigation bar when the sheet is dragged down.
    return SlideTransition(
      position: SheetOffsetDrivenAnimation(
        controller: GetIt.I<SheetController>(),
        initialValue: 1,
      ).drive(
        Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.w),topRight: Radius.circular(20.w))
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom/2),
        child: SongInfoBar(),
      ),
    );
  }
}
