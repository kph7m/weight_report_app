import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_report_app/providers/weight_providers.dart';
import 'package:weight_report_app/screens/home_screen.dart';

const _fontFamily = 'Noto Sans JP';
const _requiredImageAssets = <String>[
  'assets/images/character_pointing_input.png',
  'assets/images/cloud_top.png',
  'assets/images/cloud_bottom.png',
];

void main() {
  setUpAll(() async {
    await _loadBundledFonts();
    await _loadMaterialIconsFont();
    await _verifyRequiredImageAssets();
  });

  testWidgets('renders home screen golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weightEntriesProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFEF5EA8),
            ),
            fontFamily: _fontFamily,
            scaffoldBackgroundColor: const Color(0xFFFFF7FB),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });
    await tester.pump();
    expect(find.byType(Image), findsNWidgets(3));
    final renderImages = tester.renderObjectList<RenderImage>(
      find.byType(RawImage),
    );
    expect(renderImages, hasLength(3));
    for (final renderImage in renderImages) {
      expect(renderImage.image, isNotNull);
    }
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('../docs/screenshots/home-screen.png'),
    );
  });
}

Future<void> _loadBundledFonts() async {
  final fontLoader = FontLoader(_fontFamily)
    ..addFont(rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansJP-Bold.ttf'));
  await fontLoader.load();
}

Future<void> _loadMaterialIconsFont() async {
  final fontLoader = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await fontLoader.load();
}

Future<void> _verifyRequiredImageAssets() async {
  for (final assetPath in _requiredImageAssets) {
    final bytes = await rootBundle.load(assetPath);
    if (bytes.lengthInBytes == 0) {
      throw StateError('Required golden image asset is empty: $assetPath');
    }
  }
}
