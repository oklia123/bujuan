import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music_api/api/user/entity/user_info_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../widgets/slide.dart';

part 'provider.g.dart';

@riverpod
BoxController boxController(Ref ref) {
  return BoxController();
}

@riverpod
ZoomDrawerController zoomDrawerController(Ref ref) {
  return ZoomDrawerController();
}

@riverpod
class BoxPanelDetailData extends _$BoxPanelDetailData {
  @override
  double build() => 0;

  void updatePanelDetail(double newValue) {
    state = newValue;
  }
}

@riverpod
class CurrentRouterPath extends _$CurrentRouterPath {
  @override
  String build() => '/';

  void updatePanelDetail(String newValue) {
    if (state != newValue) {
      state = newValue;
    }
  }
}

@riverpod
Stream<MediaItem?> mediaItem(Ref ref) {
  return BujuanMusicHandler().mediaItem.stream;
}

@riverpod
Future<UserInfoEntity?> userInfo(Ref ref) async {
  var userInfo = await BujuanMusicManager().userInfo();
  return userInfo;
}
