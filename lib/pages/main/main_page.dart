import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';

import '../../common/values/app_images.dart';

class MainPage extends ConsumerWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double bottom = MediaQuery.of(context).padding.bottom;
    if (bottom == 0) bottom = 16.h;
    double bottomNavigationBarHeight =
    (MediaQuery.of(context).viewInsets.bottom > 0) ? 0 : 50;
    double appBarHeight = MediaQuery.of(context).size.height * 0.1;
    if (appBarHeight < 95) appBarHeight = 95;
    double minHeightBox =
        MediaQuery.of(context).size.height * 0.3 - bottomNavigationBarHeight;
    double maxHeightBox = MediaQuery.of(context).size.height -
        appBarHeight -
        bottomNavigationBarHeight;
    BoxController controller = BoxController();
    return Scaffold(
      body: Stack(
        children: [
          SlidingUpPanel(
            controller: ref.watch(panelControllerProvider),
            panelBuilder: () => PlayPage(),
            parallaxEnabled: true,
            parallaxOffset: 0.01,
            body: SlidingBox(
              controller: controller,
              minHeight: MediaQuery.of(context).size.height-200.w,
              maxHeight: MediaQuery.of(context).size.height,
              color: Colors.white,
              style: BoxStyle.sheet,
              draggableIconBackColor: Colors.white,
              backdrop: Backdrop(
                fading: true,
                overlay: false,
                color: Colors.white,
                body: _backdrop(),
              ),
              bodyBuilder: (sc, pos) => child,
              // collapsedBody: _collapsedBody(context),
            ),
            minHeight: 60.w,
            maxHeight: MediaQuery.of(context).size.height,
            onPanelSlide: (double value) {
              ref.read(slidingPanelDetailDataProvider.notifier).updatePanelDetail(value);
            },
          ),
        ],
      ),
    );
  }

  _backdrop() {
    return Container(
      color: Colors.grey.withOpacity(.2),
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          MaterialListItem(
              icon: const Icon(
                CupertinoIcons.house,
                size: 21,
                color: Colors.black,
              ),
              child: const Text(
                "Home",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              onPressed: () {}),
          MaterialListItem(
              icon: const Icon(
                Icons.person_outline,
                size: 26,
                color: Color(0xffeeeeee),
              ),
              child: const Text(
                "Contacts",
                style: TextStyle(color: Color(0xffeeeeee), fontSize: 18),
              ),
              onPressed: () {}),
          MaterialListItem(
              icon: const Icon(
                CupertinoIcons.camera,
                size: 22,
                color: Color(0xffeeeeee),
              ),
              child: const Text(
                "Camera",
                style: TextStyle(color: Color(0xffeeeeee), fontSize: 18),
              ),
              onPressed: () {}),
          MaterialListItem(
              icon: const Icon(
                Icons.image_outlined,
                size: 24,
                color: Color(0xffeeeeee),
              ),
              child: const Text(
                "Album",
                style: TextStyle(color: Color(0xffeeeeee), fontSize: 18),
              ),
              onPressed: () {}),
        ],
      ),
    );
  }

  _body(ScrollController sc, double pos) {
    sc.addListener(() {
      print("scrollController position: ${sc.position.pixels}");
    });
    return const Column(
      children: [
        SizedBox(
          height: 10,
        ),
        MyListItem(),
        MyListItem(),
        MyListItem(),
        MyListItem(),
        MyListItem(),
        MyListItem(),
        MyListItem(),
        MyListItem(),
        MyListItem(),
        MyListItem(),
      ],
    );
  }

  _collapsedBody(context) {
    return Center(
      child: Text(
        "Collapsed Body",
        style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 25,
            color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      // title: Padding(
      //   padding: EdgeInsets.only(left: 10.w),
      //   child: Text('Music', style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold)),
      // ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Image.asset(AppImages.search, width: 24.w, height: 24.w),
        ),
        SizedBox(width: 10.w),
      ],
    );
  }


}
class MyListItem extends StatelessWidget {
  const MyListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground.withAlpha(40),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground.withAlpha(60),
              borderRadius: const BorderRadius.all(Radius.circular(60)),
            ),
          ),
          Expanded(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 5),
                    height: 20,
                    decoration: BoxDecoration(
                      color:
                      Theme.of(context).colorScheme.onBackground.withAlpha(60),
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 9),
                    height: 13,
                    decoration: BoxDecoration(
                      color:
                      Theme.of(context).colorScheme.onBackground.withAlpha(40),
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class MaterialListItem extends StatelessWidget {
  final Icon? icon;
  final Widget child;
  final VoidCallback onPressed;

  const MaterialListItem(
      {super.key, this.icon, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    double iconSizeHeight = 50;
    return SizedBox(
      height: iconSizeHeight,
      child: MaterialButton(
        padding: const EdgeInsets.all(0),
        minWidth: MediaQuery.of(context).size.height,
        splashColor: Colors.white.withAlpha(150),
        highlightColor: Colors.white.withAlpha(150),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: onPressed,
        child: Row(
          children: [
            if (icon != null)
              SizedBox(
                width: iconSizeHeight + 10,
                height: iconSizeHeight,
                child: icon,
              ),
            child,
          ],
        ),
      ),
    );
  }
}
//开关 渐变
