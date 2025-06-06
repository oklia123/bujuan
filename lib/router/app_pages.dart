import 'package:bujuan_music/pages/mv/mv_page.dart';
import 'package:bujuan_music/pages/playlist/playlist_page.dart';
import 'package:bujuan_music/pages/setting/setting_page.dart';
import 'package:bujuan_music/pages/user/user_page.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music/splash.dart';
import 'package:go_router/go_router.dart';

import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';

class AppPages {
  static final shellRouter = [
    GoRoute(path: AppRouter.home, builder: (c, s) => const HomePage(), routes: []),
    GoRoute(path: AppRouter.playlist, builder: (c, s) => PlaylistPage(s.extra as int)),
    GoRoute(path: AppRouter.user, builder: (c, s) => UserPage()),
    GoRoute(path: AppRouter.setting, builder: (c, s) => SettingPage()),
  ];

  static final rootRouter = [
    GoRoute(path: AppRouter.login, builder: (c, s) => const LoginPage()),
    GoRoute(path: AppRouter.splash, builder: (c, s) => const SplashPage()),
    GoRoute(path: AppRouter.mv, builder: (c, s) => MvPage(s.extra as int)),
  ];
}
