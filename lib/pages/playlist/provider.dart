import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music_api/api/playlist/entity/playlist_detail_entity.dart';
import 'package:bujuan_music_api/api/song/entity/song_detail_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<PlaylistData> playlistDetail(Ref ref, int id) async {
  var playlistDetailEntity = await BujuanMusicManager().playlistDetail(id: id);
  if (playlistDetailEntity == null) {
    return PlaylistData(PlaylistDetailEntity(), []);
  }
  var songDetail = await BujuanMusicManager()
      .songDetail(ids: playlistDetailEntity.playlist!.trackIds!.map((e) => e.id ?? 0).toList());
  var medias = (songDetail?.songs ?? [])
      .map((e) => MediaItem(
          id: '${e.id}',
          title: e.name ?? "",
          duration: Duration(milliseconds: e.dt ?? 0),
          artist: (e.ar ?? []).map((e) => e.name).toList().join(' '),
          artUri: Uri.parse(e.al?.picUrl ?? ''),
          extras: {'mv': e.mv ?? 0}))
      .toList();
  return PlaylistData(playlistDetailEntity, medias);
}

class PlaylistData {
  PlaylistDetailEntity detail;
  List<MediaItem> medias;

  PlaylistData(this.detail, this.medias);
}
