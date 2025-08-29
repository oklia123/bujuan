import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData dark = ThemeData.dark(useMaterial3: false).copyWith(
      scaffoldBackgroundColor: Color(0xFF2C2C2C),
      brightness: Brightness.dark,
      iconTheme: IconThemeData().copyWith(color: Colors.white),
      appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF2C2C2C),
          titleTextStyle:
              TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w400),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          )));
  static ThemeData light = ThemeData.light(useMaterial3: false).copyWith(
      scaffoldBackgroundColor: Colors.white,
      listTileTheme: ListTileThemeData().copyWith(iconColor: Colors.black),
      brightness: Brightness.light,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontSize: 16),
          selectedIconTheme: IconThemeData(color: Colors.black),
          unselectedIconTheme: IconThemeData(color: Colors.grey),
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.black),
      appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false,
          titleTextStyle:
              TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w400),
          iconTheme: IconThemeData().copyWith(color: Colors.black),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          )));
}
