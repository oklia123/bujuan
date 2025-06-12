import 'package:bujuan_music/pages/user/provider.dart';
import 'package:bujuan_music/widgets/main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../utils/adaptive_screen_utils.dart';
import '../../widgets/cache_image.dart';
import '../../widgets/loading.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(newAlbumProvider);
    bool desktop = medium(context) || expanded(context);
    return album.when(
      data: (playlist) =>
          desktop ? DesktopUser(playlist: playlist) : MobileUser(playlist: playlist),
      loading: () => const Center(child: LoadingIndicator()),
      error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
    );
  }
}

class MobileUser extends StatelessWidget {
  final UserData playlist;

  const MobileUser({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(),
      body: ListView.builder(
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
    );
  }
}

class DesktopUser extends StatelessWidget {
  final UserData playlist;

  const DesktopUser({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.w),
          child: SizedBox(
            width: 260.w,
            child: Column(
              children: [
                CachedImage(
                  imageUrl: playlist.userInfo.profile?.avatarUrl ?? '',
                  width: 200.w,
                  height: 200.w,
                  borderRadius: 100.w,
                ),
                SizedBox(height: 15.w),
                Text(playlist.userInfo.profile?.nickname??'',style: TextStyle(
                  fontSize: 16.sp,fontWeight: FontWeight.w500
                ),),
                SizedBox(height: 10.w),
                Text(playlist.userInfo.profile?.signature??'',style: TextStyle(
                  fontSize: 12.sp,fontWeight: FontWeight.w400
                ),),
              ],
            ),
          ),
        ),
        Expanded(
            child: ListView.builder(
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
        ))
      ],
    );
  }
}
