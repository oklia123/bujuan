import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/pages/user/provider.dart';
import 'package:bujuan_music/widgets/main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/bujuan_music_handler.dart';
import '../../widgets/cache_image.dart';
import '../../widgets/loading.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final album = ref.watch(newAlbumProvider);
    return Scaffold(
      appBar: mainAppBar(),
      body: album.when(
        data: (playlist) => ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 20.w),
          itemCount: (playlist.likeList.songs??[]).length,
          separatorBuilder: (_, __) => SizedBox(height: 20.w),
          itemBuilder: (context, index) {
            final song = (playlist.likeList.songs??[])[index];
            return GestureDetector(
              child: Row(
                children: [
                  CachedImage(
                    imageUrl: song.al?.picUrl ?? '',
                    width: 52.w,
                    height: 52.w,
                    borderRadius: 26.w,
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.name ?? '',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5.w),
                        Text(
                          song.ar?.map((e) => e.name).join(' ') ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15.w),
                  const Icon(Icons.more_horiz, color: Colors.grey),
                ],
              ),
              onTap: () {
                BujuanMusicHandler().updateQueue((playlist.likeList.songs??[])
                    .map((e) => MediaItem(
                    id: '${e.id}',
                    title: e.name ?? "",
                    duration: Duration(milliseconds: e.dt ?? 0),
                    artist: (e.ar ?? []).map((e) => e.name).toList().join(' '),
                    artUri: Uri.parse(e.al?.picUrl ?? '')))
                    .toList(),index: index);

              },
            );
          },
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
      ),
    );
  }
}
