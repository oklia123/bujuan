import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music_api/api/user/entity/user_info_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.light;

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
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
Future<UserInfoEntity?> userInfo(Ref ref) async {
  return await BujuanMusicManager().userInfo();
}

@riverpod
Future<PaletteGenerator> mediaColor(Ref ref) async {
  var url = ref.watch(mediaItemProvider).value?.artUri.toString() ?? '';
  CachedNetworkImageProvider imageProvider = CachedNetworkImageProvider('$url?param=200y200');
  return await PaletteGenerator.fromImageProvider(imageProvider, size: Size(200, 200));
}
