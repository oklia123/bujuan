import 'package:bujuan_music/pages/playlist/provider.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
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
      body: album.when(
        data: (playlist) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedImage(imageUrl: playlist?.playlist?.coverImgUrl??'',width: 100.w,height: 100.w,),
            Text('${playlist?.playlist?.description}')
          ],
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
      ),
    );
  }

}
