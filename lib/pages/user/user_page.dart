import 'package:bujuan_music/pages/user/provider.dart';
import 'package:bujuan_music/widgets/main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../widgets/cache_image.dart';
import '../../widgets/loading.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(newAlbumProvider);
    return Scaffold(
      appBar: mainAppBar(),
      body: album.when(
        data: (playlist) => ListView.builder(
          padding: EdgeInsets.only(bottom: 45.w),
          itemCount: (playlist.likeList.playlist ?? []).length,
          itemBuilder: (context, index) {
            final song = (playlist.likeList.playlist ?? [])[index];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.w),
              leading: CachedImage(
                imageUrl: song.coverImgUrl?.toString() ?? '',
                width: 48.w,
                height: 48.w,
                borderRadius: 24.w,
              ),
              title: Text(song.name ?? ''),
              subtitle: Text('${song.trackCount ?? 0} songs'),
              onTap: () => context.push(AppRouter.playlist, extra: song.id),
            );
          },
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
      ),
    );
  }
}
