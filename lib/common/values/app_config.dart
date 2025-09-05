import 'package:hugeicons_pro/hugeicons.dart';

import '../../pages/main/main_page.dart';
import '../../router/app_router.dart';

class AppConfig {
  static const String ip = '127.0.0.1';
  static const int port = 8848;

  static const String isDarkTheme = 'isDarkTheme';
  static const String backgroundPath = 'backgroundPath';

  static final List<BottomData> bottomItems = [
    BottomData(HugeIconsStroke.home01, HugeIconsSolid.home01, AppRouter.home,'Home'),
    BottomData(HugeIconsStroke.lookTop,HugeIconsSolid.lookTop, AppRouter.user,'Me'),
    BottomData(HugeIconsStroke.fileMusic,HugeIconsSolid.fileMusic, AppRouter.setting,'File'),
    BottomData(HugeIconsStroke.settings02,HugeIconsSolid.settings02, AppRouter.setting,'Setting'),
  ];
}
