import 'package:flutter/material.dart';

const appFontFamily = 'Zen Maru Gothic';

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEF5EA8)),
    fontFamily: appFontFamily,
    scaffoldBackgroundColor: const Color(0xFFFFF7FB),
    useMaterial3: true,
  );
}
