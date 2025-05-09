import 'package:flutter/material.dart';

class ColorUtils {
  static Color lightenColor(Color color, [double amount = 0.2]) {
    assert(amount >= 0 && amount <= 1);
    return Color.lerp(color, Colors.white, amount)!;
  }
}
