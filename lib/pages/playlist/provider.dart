
import 'package:bujuan_music_api/api/playlist/entity/playlist_detail_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'provider.g.dart';

@riverpod
Future<PlaylistDetailEntity?> playlistDetail(Ref ref,int id) async {
  return await BujuanMusicManager().playlistDetail(id: id);
}