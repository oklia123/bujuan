import 'package:hugeicons/hugeicons.dart';

import '../../pages/main/main_page.dart';
import '../../router/app_router.dart';

class AppConfig {
  static const String ip = '127.0.0.1';
  static const int port = 8848;

  static const String isDarkTheme = 'isDarkTheme';
  static const String backgroundPath = 'backgroundPath';

  static final List<BottomData> bottomItems = [
    BottomData(HugeIcons.strokeRoundedHome01, AppRouter.home),
    BottomData(HugeIcons.strokeRoundedLookTop, AppRouter.user),
    BottomData(HugeIcons.strokeRoundedFileMusic, AppRouter.setting),
    BottomData(HugeIcons.strokeRoundedSettings02, AppRouter.setting),
  ];
}
