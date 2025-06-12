import 'package:bujuan_music/pages/setting/background_setting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopSetting();
  }
}

class DesktopSetting extends StatelessWidget {
  const DesktopSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10.w),
      child: Column(
        children: [
          ListTile(
            leading: Icon(HugeIcons.strokeRoundedAlbum01),
            title: Text('Switch the page background'),
            trailing: Icon(HugeIcons.strokeRoundedArrowRight01),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (c) => BackgroundSettingDialog(),
                  barrierColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(100));
            },
          )
        ],
      ),
    );
  }
}
