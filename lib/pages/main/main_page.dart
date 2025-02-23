import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/pages/play/play_page.dart';
import 'package:bujuan_music/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPage extends ConsumerWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double bottom = MediaQuery.of(context).padding.bottom;
    if (bottom == 0) bottom = 20.h;
    return Scaffold(
      body: SlidingUpPanel(
        controller: ref.watch(panelControllerProvider),
        panelBuilder: () => PlayPage(),
        body: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: child,
        ),
        minHeight: 60.w,
        maxHeight: MediaQuery.of(context).size.height,
        onPanelSlide: (double value) {
          ref.read(slidingPanelDetailDataProvider.notifier).updatePanelDetail(value);
        },
      ),
    );
  }
}

//开关 旋钮
