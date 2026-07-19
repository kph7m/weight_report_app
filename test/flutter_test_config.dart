import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _testFontFamily = 'Zen Maru Gothic';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadNotoSansJp();
  await _loadMaterialIcons();
  await testMain();
}

Future<void> _loadNotoSansJp() async {
  final fontLoader = FontLoader(_testFontFamily)
    ..addFont(rootBundle.load('assets/fonts/ZenMaruGothic-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/ZenMaruGothic-Bold.ttf'));
  await fontLoader.load();
}

Future<void> _loadMaterialIcons() async {
  final fontLoader = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await fontLoader.load();
}
