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
import '../main/phone/widgets.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(newAlbumProvider);
    bool desktop = medium(context) || expanded(context);
    return Scaffold(
      appBar: desktop ? null : mainAppBar(),
      body: album.when(
        data: (playlist) =>
            desktop ? DesktopUser(playlist: playlist) : MobileUser(playlist: playlist),
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
      ),
    );
  }
}

class MobileUser extends StatelessWidget {
  final UserData playlist;

  const MobileUser({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.w),
              child: Row(
                children: [
                  CachedImage(
                    imageUrl: playlist.userInfo.avatarUrl ?? "",
                    width: 40.w,
                    height: 40.w,
                    pHeight: 100,
                    pWidth: 100,
                    borderRadius: 20.w,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "Music library (${playlist.likeList.playlist?.length})",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
          SliverGrid.builder(
            itemCount: (playlist.likeList.playlist ?? []).length,
            itemBuilder: (context, index) {
              final song = (playlist.likeList.playlist ?? [])[index];
              return GestureDetector(
                child: Column(
                  children: [
                    CachedImage(
                      imageUrl: song.coverImgUrl?.toString() ?? '',
                      width: 108.w,
                      height: 108.w,
                      borderRadius: 0.w,
                      pHeight: 200,
                      pWidth: 200,
                    ),
                    Text(
                      song.name ?? '',
                      style: TextStyle(fontSize: 14.sp, overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    )
                  ],
                ),
                onTap: () => context.push(AppRouter.playlist, extra: song.id),
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: .8,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.w),
          ),
          SliverToBoxAdapter(
            child: DynamicPadding(),
          )
        ],
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
                  imageUrl: playlist.userInfo.avatarUrl ?? '',
                  width: 200.w,
                  height: 200.w,
                  borderRadius: 100.w,
                ),
                SizedBox(height: 15.w),
                Text(
                  playlist.userInfo.nickname ?? '',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10.w),
                Text(
                  playlist.userInfo.signature ?? '',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
                ),
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
