import 'package:bujuan_music/common/values/app_images.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () => getUserInfo());
    super.initState();
  }

  void getUserInfo() async {
    var userInfo = await BujuanMusicManager().userInfo();
    if (mounted) {
      context.replace((userInfo != null && userInfo.account != null) ? AppRouter.home : AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(AppImages.logo,width: 120.w,height: 120.w),
      ),
    );
  }
}
