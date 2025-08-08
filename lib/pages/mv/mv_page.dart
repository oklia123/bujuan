import 'package:bujuan_music/pages/mv/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:media_kit_video/media_kit_video.dart';

import '../../widgets/loading.dart';

class MvPage extends ConsumerStatefulWidget {
  final int id;

  const MvPage(this.id, {super.key});

  @override
  ConsumerState<MvPage> createState() => _MvPageState();
}

class _MvPageState extends ConsumerState<MvPage> {

  // late final controller = VideoController(player); 重定向

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mv = ref.watch(mvUrlProvider(widget.id));
    return Scaffold(
      appBar: AppBar(title: Text('Mv Player')),
      body: mv.when(
        data: (details) {
          // player.open(Media(details.mvUrl.data?.url ?? ''));
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9.0 / 16.0,
            // child: Video(controller: controller),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // player.dispose();
  }
}
