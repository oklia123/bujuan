import 'package:bujuan_music_api/api/recommend/entity/recommend_resource_entity.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_song_entity.dart';
import 'package:bujuan_music_api/api/song/entity/new_song_entity.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<HomeData> newAlbum(Ref ref) async {
  var recommendResourceFuture = BujuanMusicManager().recommendResource();
  var songFuture = BujuanMusicManager().newSongs(total: false);
  var recommendSongsFuture = BujuanMusicManager().recommendSongs();
  var list = await Future.wait([recommendResourceFuture, songFuture, recommendSongsFuture]);

  return HomeData(
      list[0] as RecommendResourceEntity, list[1] as NewSongEntity, list[2] as RecommendSongEntity);
}

class HomeData {
  // TopArtistEntity topArtistEntity;
  RecommendResourceEntity recommendResourceEntity;
  NewSongEntity newSongEntity;
  RecommendSongEntity recommendSongEntity;

  HomeData(this.recommendResourceEntity, this.newSongEntity, this.recommendSongEntity);
}
