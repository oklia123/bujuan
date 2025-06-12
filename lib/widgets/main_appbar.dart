import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';

AppBar mainAppBar() {
  return AppBar(
    backgroundColor: Colors.transparent,
    leading: IconButton(
        onPressed: () => GetIt.I<ZoomDrawerController>().toggle?.call(),
        icon: Icon(HugeIcons.strokeRoundedInbox)),
    title: Text('BuJuan'),
    actions: [
      IconButton(onPressed: (){}, icon: Icon(HugeIcons.strokeRoundedSearch01))
    ],
  );
}
