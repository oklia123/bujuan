import 'package:bujuan_music/common/values/app_images.dart';
import 'package:bujuan_music/pages/home/provider.dart';
import 'package:bujuan_music/widgets/cache_image.dart';
import 'package:bujuan_music/widgets/loading.dart';
import 'package:bujuan_music_api/api/song/entity/new_song_entity.dart';
import 'package:bujuan_music_api/api/top/entity/top_artist_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.w),
      child: Consumer(
        builder: (context, ref, child) {
          final album = ref.watch(newAlbumProvider);
          return album.when(
            data: (homeData) => _buildContent(homeData),
            loading: () => const Center(child: LoadingIndicator()),
            error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
          );
        },
      ),
    );
  }

  Widget _buildContent(HomeData homeData) {
    final albumList = homeData.topArtistEntity.artists;
    final songList = homeData.newSongEntity.data ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 60.w),
      child: Column(
        children: [
          SizedBox(height: 15.w),
          Image.asset(AppImages.banner, width: 340.w, height: 148.w, fit: BoxFit.cover),
          _buildTitle('Top Album', onTap: () {}),
          _buildAlbumList(albumList),
          _buildTitle('Song List', onTap: () {}),
          _buildSongList(songList),
        ],
      ),
    );
  }

  Widget _buildAlbumList(List<TopArtistArtists> artists) {
    return SizedBox(
      height: 198.w,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        separatorBuilder: (_, __) => SizedBox(width: 15.w),
        itemBuilder: (context, index) {
          final album = artists[index];
          return SizedBox(
            width: 148.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedImage(
                  imageUrl: album.picUrl ?? '',
                  width: 148.w,
                  height: 172.w,
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
          );
        },
      ),
    );
  }

  Widget _buildSongList(List<NewSongData> songs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const PageScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: songs.length > 6 ? 6 : songs.length,
      separatorBuilder: (_, __) => SizedBox(height: 20.w),
      itemBuilder: (context, index) {
        final song = songs[index];
        return Row(
          children: [
            CachedImage(
              imageUrl: song.album?.blurPicUrl ?? '',
              width: 52.w,
              height: 52.w,
              borderRadius: 16.w,
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
                    song.artists?.map((e) => e.name).join(' ') ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
            const Icon(Icons.more_horiz, color: Colors.grey),
          ],
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
