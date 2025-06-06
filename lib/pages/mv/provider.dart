import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music_api/api/mv/entity/mv_url_entity.dart';
import 'package:bujuan_music_api/api/playlist/entity/playlist_detail_entity.dart';
import 'package:bujuan_music_api/api/song/entity/song_detail_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<MvData> mvUrl(Ref ref, int id) async {
  var mv = await BujuanMusicManager().mvUrl(id: id);
  return MvData(mv ?? MvUrlEntity());
}

class MvData {
  MvUrlEntity mvUrl;

  MvData(this.mvUrl);
}
