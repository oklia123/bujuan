import 'package:bujuan_music_api/api/recommend/entity/recommend_resource_entity.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_song_entity.dart';
import 'package:bujuan_music_api/api/song/entity/song_detail_entity.dart';
import 'package:bujuan_music_api/api/user/entity/like_list_entity.dart';
import 'package:bujuan_music_api/api/user/entity/user_playlist_entity.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<UserData> newAlbum(Ref ref) async {
  var userInfo = await BujuanMusicManager().userInfo();
  var userPlaylistEntity =
      await BujuanMusicManager().userPlaylist(uid: '${userInfo?.profile?.userId ?? 0}');
  return UserData(userPlaylistEntity ?? UserPlaylistEntity());
}

class UserData {
  UserPlaylistEntity likeList;

  UserData(this.likeList);
}
