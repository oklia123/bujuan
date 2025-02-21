import 'package:bujuan_music/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:statusbarz/statusbarz.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return StatusbarzCapturer(
        child: ScreenUtilInit(
          designSize: Size(375, 812),
          builder: (_,__) => MaterialApp.router(
            title: 'Flutter Demo',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: false,
                scaffoldBackgroundColor: Colors.white
            ),
            routerConfig: router,
          ),
        ));
  }
}
