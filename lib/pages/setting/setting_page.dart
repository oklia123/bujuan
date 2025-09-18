import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopSetting();
  }
}

class DesktopSetting extends StatelessWidget {
  const DesktopSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            Consumer(builder: (context, ref, child) {
              var homeStyle = ref.watch(homeStyleProvider);
              return ListTile(
                title: Text('切换首页样式'),
                subtitle: Text(homeStyle == HomeStyleType.draw ? '侧边栏' : '底部栏'),
                onTap: () {
                  ref.read(homeStyleProvider.notifier).setIndex(
                      homeStyle == HomeStyleType.draw ? HomeStyleType.bottomBar : HomeStyleType.draw);
                  context.replace(AppRouter.home);

                },
              );
            })
          ],
        ),
      ),
    );
  }
}
