import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/common/values/app_theme.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/router/router.dart';
import 'package:bujuan_music/utils/adaptive_screen_utils.dart';
import 'package:bujuan_music/widgets/slide.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await startLocalRedirectServer();
  await initMedia();
  await initWindow();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // 底部手势栏透明
      statusBarColor: Colors.transparent));
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<ZoomDrawerController>(ZoomDrawerController());
  getIt.registerSingleton<BoxController>(BoxController());
  // 让布局真正覆盖状态栏和底部手势栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(ProviderScope(child: MyApp()));
}

/// 初始化窗口
Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    WindowOptions windowOptions = WindowOptions(
      size: Size(1024, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

/// 初始化音频服务
Future<void> initMedia() async {
  MediaKit.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  await BujuanMusicManager().init(cookiePath: '${appDocDir.path}/cookies', debug: false);
  await AudioService.init(
    builder: () => BujuanMusicHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.sixbugs.bujuan.channel.audio',
      androidNotificationChannelName: 'Music playback',
    ),
  );
}

/// 开启本地代理服务
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
    Size size = Size(375, 812);
    if (medium(context) || expanded(context)) {
      size = Size(1024, 600);
    }

    return ScreenUtilInit(
      designSize: size,
      builder: (_, __) => Consumer(builder: (_, ref, __) {
        final themeMode = ref.watch(themeModeNotifierProvider);
        return MaterialApp.router(
          title: 'Bujuan',
          themeMode: themeMode,
          darkTheme: AppTheme.dark,
          showPerformanceOverlay: false,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: router,
        );
      }),
    );
  }
}
