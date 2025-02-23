import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music/widgets/curved_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 2000), () {
      // 让状态栏和底部导航栏都透明
      goHome();
    });
    super.initState();
  }

  goHome() {
    context.replace(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: CurvedProgressBar(progress: .8),
      ),
    );
  }
}
