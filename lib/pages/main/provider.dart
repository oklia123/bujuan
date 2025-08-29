import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/common/values/app_config.dart';
import 'package:bujuan_music/common/values/app_images.dart';
import 'package:bujuan_music/widgets/we_slider/weslide_controller.dart';
import 'package:bujuan_music_api/api/mv/entity/mv_url_entity.dart';
import 'package:bujuan_music_api/api/user/entity/user_info_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() =>
      (GetIt.I<Box>().get(AppConfig.isDarkTheme) ?? false) ? ThemeMode.dark : ThemeMode.light;

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

@riverpod
WeSlideController weSlideController(Ref ref) {
  return WeSlideController();
}

@riverpod
class BackgroundModeNotifier extends _$BackgroundModeNotifier {
  @override
  String build() => (GetIt.I<Box>().get(AppConfig.backgroundPath) ?? AppImages.happy);

  void changeBackground(String background) {
    state = background;
  }
}

@riverpod
class CurrentIndex extends _$CurrentIndex {
  @override
  int build() => 0; // 初始值

  void setIndex(int index) {
    state = index; // 修改值
  }
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
Stream<PlaybackState?> playbackState(Ref ref) {
  return BujuanMusicHandler().playbackState.stream;
}

@riverpod
Stream<Duration> playbackPosition(Ref ref) {
  return BujuanMusicHandler().currentPosition;
}
// _player.onPositionChanged

@riverpod
Future<UserInfoEntity?> userInfo(Ref ref) async {
  return await BujuanMusicManager().userInfo();
}

@riverpod
Future<MvUrlEntity?> mvUrl(Ref ref) async {
  // var url = ref.watch(mediaItemProvider).value.extras?['mvId'];
  // return await BujuanMusicManager().mvUrl(id: id);
}

@riverpod
Future<UserInfoEntity?> lyric(Ref ref) async {
  return await BujuanMusicManager().userInfo();
}

@riverpod
Future<PaletteGenerator> mediaColor(Ref ref) async {
  var url = ref.watch(mediaItemProvider).value?.artUri.toString() ?? '';
  CachedNetworkImageProvider imageProvider = CachedNetworkImageProvider('$url?param=100y100');
  return await PaletteGenerator.fromImageProvider(imageProvider, size: Size(300, 300));
}

/// 播放模式
@riverpod
class LoopModeNotifier extends _$LoopModeNotifier {
  @override
  LoopMode build() => LoopMode.playlist;

  void changeMode() {
    switch (BujuanMusicHandler().loopMode) {
      case LoopMode.one:
        state = LoopMode.playlist;
        break;
      case LoopMode.playlist:
        state = LoopMode.shuffle;
        break;
      case LoopMode.shuffle:
        state = LoopMode.one;
        break;
    }
    BujuanMusicHandler().setLoopMode(state);
  }
}
