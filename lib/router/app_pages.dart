import 'package:bujuan_music/pages/playlist/playlist_page.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:go_router/go_router.dart';

import '../pages/home/home_page.dart';

class AppPages {
  static final shellRouter = [
    GoRoute(path: AppRouter.home, builder: (c, s) => const HomePage(), routes: []),
    GoRoute(path: AppRouter.playlist, builder: (c, s) => PlaylistPage()),
    // GoRoute(path: '/user', builder: (c, s) => const User()),
    // GoRoute(path: '/login', builder: (c, s) => const LoginViewPage()),
  ];
}
