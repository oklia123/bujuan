import 'package:bujuan_music/pages/home/provider.dart';
import 'package:bujuan_music/pages/main/phone/widgets.dart';
import 'package:bujuan_music/widgets/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/loading.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended daily'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final album = ref.watch(recommendSongsProvider);
          return album.when(
            data: (today) => ListView.builder(
              itemBuilder: (context, index) => index == today.length
                  ? DynamicPadding(hasBottom: false)
                  : MediaItemWidget(mediaItem: today[index]),
              itemCount: today.length + 1,
            ),
            loading: () => const Center(child: LoadingIndicator()),
            error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
          );
        },
      ),
    );
  }
}
