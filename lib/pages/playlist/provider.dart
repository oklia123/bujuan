import 'package:bujuan_music_api/api/playlist/entity/playlist_detail_entity.dart';
import 'package:bujuan_music_api/api/song/entity/song_detail_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<SongDetailEntity?> playlistDetail(Ref ref, int id) async {
  var playlistDetailEntity = await BujuanMusicManager().playlistDetail(id: id);
  return await BujuanMusicManager()
      .songDetail(ids: playlistDetailEntity!.playlist!.trackIds!.map((e) => '${e.id}').toList());
}
