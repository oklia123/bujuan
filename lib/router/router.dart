import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/router/app_pages.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/main/main_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final routerKey = GlobalKey<NavigatorState>(debugLabel: 'routerKey');
  final shellKey = GlobalKey<NavigatorState>(debugLabel: 'shellKey');

  final router = GoRouter(
    navigatorKey: routerKey,
    debugLogDiagnostics: true,
    initialLocation: AppRouter.home,
    routes: [
      ShellRoute(
        routes: AppPages.shellRouter,
        navigatorKey: shellKey,
        // observers: [BujuanObserver(ref: ref)],
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            MainPage(child: child),
      ),
      ...AppPages.rootRouter
    ],
  );
  ref.onDispose(router.dispose); // always clean up after yourselves (:
  return router;
}

class BujuanObserver extends NavigatorObserver {
  final Ref ref;

  BujuanObserver({required this.ref});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _showOrHideFooter(route.settings.name ?? '');



  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _showOrHideFooter(previousRoute?.settings.name ?? '');
  }
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _showOrHideFooter(newRoute?.settings.name ?? '');
  }

  _showOrHideFooter(String name) {
    print('_showOrHideFooter========$name');
    if (name.isEmpty) return;
    ref.read(currentRouterPathProvider.notifier).updatePanelDetail(name);
  }
}
