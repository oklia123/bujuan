import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/router/router.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await startLocalRedirectServer();
  MediaKit.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // 底部手势栏透明
      statusBarColor: Colors.transparent));
  final appDocDir = await getApplicationDocumentsDirectory();
  await BujuanMusicManager().init(cookiePath: '${appDocDir.path}/cookies', debug: false);
  GetIt getIt = GetIt.instance;
  BujuanMusicHandler audioHandler = await AudioService.init(
    builder: () => BujuanMusicHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.sixbugs.bujuan.channel.audio',
      androidNotificationChannelName: 'Music playback',
    ),
  );
  getIt.registerSingleton<BujuanMusicHandler>(audioHandler);
  getIt.registerSingleton<ZoomDrawerController>(ZoomDrawerController());
  // 让布局真正覆盖状态栏和底部手势栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(ProviderScope(child: MyApp()));
}

Future<void> startLocalRedirectServer() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8848);
  log('Server running at http://${server.address.host}:${server.port}');
  server.listen((HttpRequest request) async {
    final path = request.uri.path;
    if (path.startsWith('/song/')) {
      final songId = path.split('/').last;
      final realUrl = await BujuanMusicHandler().getSongUrl(songId);
      log('$songId--------------$realUrl');
      request.response.statusCode = 302;
      request.response.headers.set('location', realUrl);
      await request.response.close();
    } else {
      request.response
        ..statusCode = 404
        ..write('Not found')
        ..close();
    }
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (_, __) => MaterialApp.router(
        title: 'Flutter Demo',
        showPerformanceOverlay: false,
        theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: false,
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                titleTextStyle: TextStyle(color: Colors.black))),
        routerConfig: router,
      ),
    );
  }
}
