import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/pages/playlist/provider.dart';
import 'package:bujuan_music/widgets/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/loading.dart';

class PlaylistPage extends ConsumerWidget {
  final int id;

  const PlaylistPage(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(playlistDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text('Playlist')),
      body: album.when(
        data: (details) => ListView.builder(
          padding: EdgeInsets.only(top: 0,bottom: 45.w),
          itemCount: details.medias.length,
          itemBuilder: (context, index) => MediaItemWidget(
            mediaItem: details.medias[index],
            onTap: () => BujuanMusicHandler().updateQueue(details.medias, index: index),
          ),
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
      ),
    );
  }
}
