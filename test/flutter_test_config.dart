import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadNotoSansJp();
  await _loadZenMaruGothic();
  await _loadMaterialIcons();
  await testMain();
}

Future<void> _loadNotoSansJp() async {
  final fontLoader = FontLoader('Noto Sans JP')
    ..addFont(rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansJP-Bold.ttf'));
  await fontLoader.load();
}

Future<void> _loadZenMaruGothic() async {
  final fontLoader = FontLoader('Zen Maru Gothic')
    ..addFont(rootBundle.load('assets/fonts/ZenMaruGothic-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/ZenMaruGothic-Bold.ttf'));
  await fontLoader.load();
}

Future<void> _loadMaterialIcons() async {
  final fontLoader = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await fontLoader.load();
}
