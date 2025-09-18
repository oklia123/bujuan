import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_resource_entity.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_song_entity.dart';
import 'package:bujuan_music_api/api/song/entity/new_song_entity.dart';
import 'package:bujuan_music_api/api/top/entity/top_artist_entity.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<HomeData> newAlbum(Ref ref) async {
  var recommendResourceFuture = BujuanMusicManager().recommendResource();
  var recommendSongsFuture = BujuanMusicManager().newSongs();
  var topArtistFuture = BujuanMusicManager().topArtist(limit: 10);
  var list = await Future.wait([recommendResourceFuture, topArtistFuture, recommendSongsFuture]);
  var listArtist = list[1] as TopArtistEntity;
  var songEntity = list[2] as NewSongEntity;
  var songs = (songEntity.data ?? []);
  return HomeData(
      list[0] as RecommendResourceEntity,
      listArtist,
      (songs.length > 20 ? songs.sublist(0, 20) : songs)
          .map((e) => MediaItem(
              id: '${e.id}',
              title: e.name ?? "",
              duration: Duration(milliseconds: e.duration ?? 0),
              artist: (e.artists ?? []).map((e) => e.name).toList().join(' '),
              artUri: Uri.parse(e.album?.picUrl ?? ''),
              extras: {'mv': e.mvid ?? 0}))
          .toList());
}

@riverpod
Future<List<MediaItem>> recommendSongs(Ref ref) async {
  var recommendSongEntity = await BujuanMusicManager().recommendSongs();
  var list = recommendSongEntity?.data?.dailySongs ?? [];
  return list
      .map((e) => MediaItem(
          id: '${e.id}',
          title: e.name ?? "",
          duration: Duration(milliseconds: e.dt ?? 0),
          artist: (e.ar ?? []).map((e) => e.name).toList().join(' '),
          artUri: Uri.parse(e.al?.picUrl ?? ''),
          extras: {'mv': e.mv ?? 0}))
      .toList();
}

class HomeData {
  // TopArtistEntity topArtistEntity;
  RecommendResourceEntity recommendResourceEntity;
  TopArtistEntity topArtistEntity;
  List<MediaItem> medias;

  HomeData(this.recommendResourceEntity, this.topArtistEntity, this.medias);
}
