import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music/widgets/curved_progress_bar.dart';
import 'package:bujuan_music/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:o3d/o3d.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  O3DController o3dController = O3DController();

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () => goHome());
    super.initState();
  }

  goHome() async {
    var list = await o3dController.availableAnimations();
    for (var e in list) {
      print('object===============$e');
    }
    o3dController.play(repetitions: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: O3D.asset(
          src: 'assets/images/su7.glb',
          controller: o3dController,
          autoRotate: false,
        ),
      ),
    );
  }
}
