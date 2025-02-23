import 'package:flutter/material.dart';

class TitleBar extends AppBar {
  TitleBar({
    super.key,
    required String title,
    super.actions,
    super.bottom,
  }) : super(
          title: Text(title),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        );
}
