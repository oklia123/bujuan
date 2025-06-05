import 'package:bujuan_music_api/api/recommend/entity/recommend_resource_entity.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_song_entity.dart';
import 'package:bujuan_music_api/api/song/entity/song_detail_entity.dart';
import 'package:bujuan_music_api/api/user/entity/like_list_entity.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<UserData> newAlbum(Ref ref) async {
  var userInfo = await BujuanMusicManager().userInfo();
  var recommendResourceFuture = await BujuanMusicManager().userLikeList(uid: '${userInfo?.profile?.userId??0}');
  var songDetailEntity = await BujuanMusicManager().songDetail(ids: (recommendResourceFuture?.ids??[]).map((e) => '$e').toList());
  return UserData(songDetailEntity!);
}

class UserData {
  SongDetailEntity likeList;

  UserData(this.likeList);
}
