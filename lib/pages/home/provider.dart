import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_resource_entity.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_song_entity.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<HomeData> newAlbum(Ref ref) async {
  var recommendResourceFuture = BujuanMusicManager().recommendResource();
  var recommendSongsFuture = BujuanMusicManager().recommendSongs();
  BujuanMusicManager().topArtist();
  var list = await Future.wait([recommendResourceFuture, recommendSongsFuture]);
  var songEntity = list[1] as RecommendSongEntity;
  return HomeData(
      list[0] as RecommendResourceEntity,
      (songEntity.data?.dailySongs ?? [])
          .map((e) => MediaItem(
              id: '${e.id}',
              title: e.name ?? "",
              duration: Duration(milliseconds: e.dt ?? 0),
              artist: (e.ar ?? []).map((e) => e.name).toList().join(' '),
              artUri: Uri.parse(e.al?.picUrl ?? ''),
              extras: {'mv': e.mv ?? 0}))
          .toList());
}

class HomeData {
  // TopArtistEntity topArtistEntity;
  RecommendResourceEntity recommendResourceEntity;
  List<MediaItem> medias;

  HomeData(this.recommendResourceEntity, this.medias);
}
