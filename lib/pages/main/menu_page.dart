import 'package:bujuan_music/pages/main/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../router/app_router.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer(builder: (context, ref, child) {
      var currentPath = ref.watch(currentRouterPathProvider);
      var theme = ref.watch(themeModeNotifierProvider);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            minLeadingWidth: 20.w,
            leading: Icon(
              HugeIcons.strokeRoundedHome01,
              color: currentPath == AppRouter.home ? Colors.red : null,
            ),
            title: Text(
              'Home',
              style: TextStyle(color: currentPath == AppRouter.home ? Colors.red : null),
            ),
            onTap: () {
              context.replace(AppRouter.home);
              GetIt.I<ZoomDrawerController>().toggle?.call();
            },
          ),
          ListTile(
            minLeadingWidth: 20.w,
            leading: Icon(HugeIcons.strokeRoundedUser,
                color: currentPath == AppRouter.user ? Colors.red : null),
            title: Text(
              'User',
              style: TextStyle(color: currentPath == AppRouter.user ? Colors.red : null),
            ),
            onTap: () {
              context.replace(AppRouter.user);
              GetIt.I<ZoomDrawerController>().toggle?.call();
            },
          ),
          ListTile(
            leading: Icon(
              HugeIcons.strokeRoundedSettings03,
              color: currentPath == AppRouter.setting ? Colors.red : null,
            ),
            minLeadingWidth: 20.w,
            title: Text(
              'Setting',
              style: TextStyle(color: currentPath == AppRouter.setting ? Colors.red : null),
            ),
            onTap: () {
              context.replace(AppRouter.setting);
              GetIt.I<ZoomDrawerController>().toggle?.call();
            },
          ),
          ListTile(
            minLeadingWidth: 20.w,
            leading: Icon(
              theme == ThemeMode.dark
                  ? HugeIcons.strokeRoundedSunCloud02
                  : HugeIcons.strokeRoundedMoon01,
            ),
            title: Text('Theme Mode'),
            onTap: () => ref.read(themeModeNotifierProvider.notifier).toggleTheme(),
          )
        ],
      );
    }),);
  }
}
