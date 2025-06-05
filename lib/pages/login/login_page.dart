import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    inta();
    super.initState();
  }

  inta()async{
    // await BujuanMusicManager().sendSmsCode(phone: '13223087330');
    // await BujuanMusicManager().verifySmsCode(phone: '13223087330', captcha: '8357');
    await BujuanMusicManager().loginCellPhone(phone: '13223087330',captcha: '3628');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

        ],
      ),
    );
  }
}
