import 'dart:convert';

import 'package:bujuan_music/common/values/app_config.dart';
import 'package:bujuan_music_api/api/user/entity/user_info_entity.dart';
import 'package:bujuan_music_api/api/user/entity/user_playlist_entity.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<UserData> newAlbum(Ref ref) async {
  try {
    String userInfo = GetIt.I<Box>().get(AppConfig.userInfoKey, defaultValue: '');
    if (userInfo.isNotEmpty) {
      var user = UserInfoProfile.fromJson(jsonDecode(userInfo));
      var userPlaylistEntity = await BujuanMusicManager().userPlaylist(uid: '${user.userId ?? 0}');
      return UserData(userPlaylistEntity ?? UserPlaylistEntity(), user);
    }
    return UserData(UserPlaylistEntity(), UserInfoProfile());
  } catch (e) {
    return UserData(UserPlaylistEntity(), UserInfoProfile());
  }
}

class UserData {
  UserPlaylistEntity likeList;
  UserInfoProfile userInfo;

  UserData(this.likeList, this.userInfo);
}
