import 'package:bujuan_music_api/api/song/entity/new_song_entity.dart';
import 'package:bujuan_music_api/api/top/entity/top_artist_entity.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<HomeData> newAlbum(Ref ref) async {
  // var albumFuture = BujuanMusicManager().newAlbum(limit: 6);
  var artistFuture = BujuanMusicManager().topArtist(limit: 6);
  var songFuture = BujuanMusicManager().newSongs(total: false);
  var list = await Future.wait([artistFuture, songFuture]);

  return HomeData(list[0] as TopArtistEntity , list[1] as NewSongEntity);
}


class HomeData {
  TopArtistEntity topArtistEntity;
  NewSongEntity newSongEntity;

  HomeData(this.topArtistEntity, this.newSongEntity);
}
