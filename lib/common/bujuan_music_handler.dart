import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bujuan_music/common/values/app_config.dart';
import 'package:bujuan_music_api/api/song/entity/song_url_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class BujuanMusicHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  /// 播放器实例
  final Player _player = Player();

  /// 是否播放中断
  bool _playInterrupted = false;

  /// 监听音频中断时间
  StreamSubscription<void>? _becomingNoisyEventSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionEventSubscription;

  factory BujuanMusicHandler() => _getInstance ??= BujuanMusicHandler._();

  static BujuanMusicHandler? _getInstance;

  BujuanMusicHandler._() {
    _init();
  }

  bool _isAndroid() => !kIsWeb && Platform.isAndroid;

  void _init() {
    _initAudioSession();
    _notifyAudioHandlerAboutPlayStateEvents();
  }

  /// 更新播放列表
  @override
  Future<void> updateQueue(List<MediaItem> queueList, {int index = 0}) async {
    if (queueList.isEmpty) return;
    await _player.open(Playlist(queueList.map((e) => Media(_mediaUrl(e.id))).toList(),index: index),
        play: true);
    mediaItem.add(queueList[index]);
    super.updateQueue(queueList);
  }

  /// 向播放列表添加单个歌曲
  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _player.add(Media(_mediaUrl(mediaItem.id)));
    super.addQueueItem(mediaItem);
  }

  /// 向播放列表插入单个歌曲
  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _player.add(Media(_mediaUrl(mediaItem.id)));
    await _player.move(queue.value.length - 1, index);
    super.insertQueueItem(index, mediaItem);
  }

  /// 从播放列表中删除指定曲目
  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    var index = queue.value.indexWhere((e) => e.id == mediaItem.id);
    if (index != -1) {
      await _player.remove(index);
    }
  }

  /// 从播放列表中删除指定下标
  @override
  Future<void> removeQueueItemAt(int index) async {
    await _player.remove(index);
  }

  /// 播放
  @override
  Future<void> play() async {
    _playInterrupted = false;
    await _player.play();
  }

  Future<void> playOrPause() async {
    _playInterrupted = false;
    await _player.playOrPause();
  }

  /// 暂停
  @override
  Future<void> pause() async {
    _playInterrupted = false;
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _playInterrupted = false;
    _player.stop();
    super.stop();
  }

  Future<void> dispose() async {
    _becomingNoisyEventSubscription?.cancel();
    _interruptionEventSubscription?.cancel();
    await _player.dispose();
  }

  /// 下一首
  @override
  Future<void> skipToNext() async {
    await _player.next();
    return super.skipToNext();
  }

  /// 上一首
  @override
  Future<void> skipToPrevious() async {
    await _player.previous();
    return super.skipToPrevious();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// 根据id获取播放地址
  Future<String> getSongUrl(String id) async {
    SongUrlEntity? songUrlEntity = await BujuanMusicManager().songUrl(ids: [id]);
    if (songUrlEntity != null && (songUrlEntity.data ?? []).isNotEmpty) {
      List<SongUrlData> songUrlList = songUrlEntity.data!;
      return songUrlList.first.url ?? '';
    }
    return '';
  }

  /// 同步状态
  void _notifyAudioHandlerAboutPlayStateEvents() {
    _player.stream
      ..playing.listen((playing) => _broadcastState(playing: playing))
      ..position.listen(
          (position) => playbackState.add(playbackState.value.copyWith(updatePosition: position)))
      ..buffer.listen(
          (buffer) => playbackState.add(playbackState.value.copyWith(bufferedPosition: buffer)))
      ..rate.listen((rate) => playbackState.add(playbackState.value.copyWith(speed: rate)))
      ..playlist.listen((playlist) {
        playbackState.add(playbackState.value.copyWith(queueIndex: playlist.index));
        if (queue.value.isNotEmpty) {
          mediaItem.add(queue.value[playlist.index]);
        }
      });
  }

  /// 同步状态
  void _broadcastState({
    bool? playing,
    AudioProcessingState processingState = AudioProcessingState.ready,
  }) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        (playing ?? _player.state.playing) ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: playing ?? _player.state.playing,
    ));
  }

  /// 初始化AudioSession
  _initAudioSession() async {
    AudioSession session = await AudioSession.instance;
    _becomingNoisyEventSubscription = session.becomingNoisyEventStream.listen((_) => pause());
    _interruptionEventSubscription = session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            assert(_isAndroid());
            if (session.androidAudioAttributes!.usage == AndroidAudioUsage.game) {
              _player.setVolume(_player.state.volume / 2);
            }
            _playInterrupted = false;
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            if (_player.state.playing) {
              pause();
              _playInterrupted = true;
            }
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            assert(_isAndroid());
            _player.setVolume(_player.state.volume / 2);
            _playInterrupted = false;
            break;
          case AudioInterruptionType.pause:
            if (_playInterrupted) play();
            _playInterrupted = false;
            break;
          case AudioInterruptionType.unknown:
            _playInterrupted = false;
            break;
        }
      }
    });
  }

  /// 拼接url
  String _mediaUrl(String id) => 'http://${AppConfig.ip}:${AppConfig.port}/song/$id';
}
