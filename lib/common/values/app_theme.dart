import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark = ThemeData.dark(useMaterial3: false).copyWith(
    scaffoldBackgroundColor: Color(0xFF2C2C2C),
  );
  static ThemeData light = ThemeData.light(useMaterial3: false).copyWith(
    scaffoldBackgroundColor: Colors.white,
    listTileTheme: ListTileThemeData().copyWith(iconColor: Colors.black),
  );
}
