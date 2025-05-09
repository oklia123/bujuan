import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music/common/values/app_images.dart';
import 'package:bujuan_music/pages/home/provider.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:bujuan_music/widgets/loading.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_resource_entity.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_song_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.w),
      child: Consumer(
        builder: (context, ref, child) {
          final album = ref.watch(newAlbumProvider);
          return album.when(
            data: (homeData) => _buildContent(homeData,context,ref),
            loading: () => const Center(child: LoadingIndicator()),
            error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
          );
        },
      ),
    );
  }

  Widget _buildContent(HomeData homeData,BuildContext context,WidgetRef ref) {
    final albumList = homeData.recommendResourceEntity.recommend;
    final songList = homeData.recommendSongEntity.data?.dailySongs ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 60.w),
      child: Column(
        children: [
          SizedBox(height: 10.w),
          GestureDetector(
            child: Image.asset(AppImages.banner, width: 340.w, height: 148.w, fit: BoxFit.cover),
            onTap: (){
             var read = ref.read(themeModeNotifierProvider.notifier);
             read.toggleTheme();
            },
          ),
          _buildTitle('Top Album', onTap: () {}),
          _buildAlbumList(albumList),
          _buildTitle('Song List', onTap: () {}),
          _buildSongList(songList),
        ],
      ),
    );
  }

  Widget _buildAlbumList(List<RecommendResourceRecommend> artists) {
    return SizedBox(
      height: 178.w,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        separatorBuilder: (_, __) => SizedBox(width: 15.w),
        itemBuilder: (context, index) {
          final album = artists[index];
          return GestureDetector(
            child: SizedBox(
              width: 148.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedImage(
                    imageUrl: album.picUrl ?? '',
                    width: 148.w,
                    height: 148.w,
                    fit: BoxFit.cover,
                    borderRadius: 16.w,
                  ),
                  SizedBox(height: 3.w),
                  Text(
                    '  ${album.name}',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            onTap: (){
              context.push(AppRouter.playlist,extra: artists[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildSongList(List<RecommendSongDataDailySongs> songs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const PageScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: songs.length,
      separatorBuilder: (_, __) => SizedBox(height: 20.w),
      itemBuilder: (context, index) {
        final song = songs[index];
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
            BujuanMusicHandler().updateQueue(songs
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
    );
  }

  Widget _buildTitle(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: TextStyle(
                        fontSize: 14.sp, color: Color(0xFFFF2C53), fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.keyboard_arrow_right_outlined, size: 20.sp, color: Color(0xFFFF2C53)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
