import 'package:bujuan_music/router/router.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // 底部手势栏透明
      statusBarColor: Colors.transparent));
  final appDocDir = await getApplicationDocumentsDirectory();
  await BujuanMusicManager().init(cookiePath: '${appDocDir.path}/cookies', debug: false);
  // 让布局真正覆盖状态栏和底部手势栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(ProviderScope(child: MyApp()));
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
        showPerformanceOverlay: true,
        theme:
            ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white, useMaterial3: false,appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,elevation: 0,titleTextStyle: TextStyle(
              color: Colors.black
            )
            )),
        routerConfig: router,
      ),
    );
  }
}
