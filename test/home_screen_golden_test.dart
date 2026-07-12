import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_report_app/models/weight_entry.dart';
import 'package:weight_report_app/providers/weight_providers.dart';
import 'package:weight_report_app/services/weight_repository.dart';
import 'package:weight_report_app/screens/home_screen.dart';
import 'package:weight_report_app/screens/report_screen.dart';

const _fontFamily = 'Noto Sans JP';
const _requiredImageAssets = <String>[
  'assets/images/character_pointing_input.png',
  'assets/images/character_high_touch.png',
  'assets/images/character_report.png',
  'assets/images/character_celebration.png',
  'assets/images/cloud_top.png',
  'assets/images/cloud_bottom.png',
];

Future<void> _pumpHomeScreen(
  WidgetTester tester, {
  WeightRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        weightEntriesProvider.overrideWith((ref) => Stream.value(const [])),
        if (repository != null)
          weightRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEF5EA8)),
          fontFamily: _fontFamily,
          scaffoldBackgroundColor: const Color(0xFFFFF7FB),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pump();
}

String? _assetNameForSemanticLabel(WidgetTester tester, String semanticLabel) {
  final image = tester.widget<Image>(
    find.byWidgetPredicate(
      (widget) => widget is Image && widget.semanticLabel == semanticLabel,
    ),
  );
  final provider = image.image;
  return provider is AssetImage ? provider.assetName : null;
}

class _FakeWeightRepository implements WeightRepository {
  _FakeWeightRepository({this.saveError});

  final Object? saveError;
  final savedWeights = <double>[];

  @override
  Future<void> saveToday(double weightKg) async {
    final saveError = this.saveError;
    if (saveError != null) throw saveError;

    savedWeights.add(weightKg);
  }

  @override
  Stream<List<WeightEntry>> watchEntries() => Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    await _verifyRequiredImageAssets();
  });

  testWidgets('renders home screen golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpHomeScreen(tester);
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

  testWidgets('shows high touch character after weight input reaches 30.0', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpHomeScreen(tester);
    expect(
      _assetNameForSemanticLabel(tester, '体重入力キャラクター'),
      'assets/images/character_pointing_input.png',
    );

    await tester.enterText(find.byType(TextFormField), '29.9');
    await tester.pumpAndSettle();
    expect(
      _assetNameForSemanticLabel(tester, '体重入力キャラクター'),
      'assets/images/character_pointing_input.png',
    );

    await tester.enterText(find.byType(TextFormField), '30.0');
    await tester.pumpAndSettle();
    expect(
      _assetNameForSemanticLabel(tester, '体重入力キャラクター'),
      'assets/images/character_pointing_input.png',
    );

    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });
    await tester.pump();
    expect(
      _assetNameForSemanticLabel(tester, '体重入力キャラクター'),
      'assets/images/character_high_touch.png',
    );
    final characterRenderImages = tester.renderObjectList<RenderImage>(
      find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is Image && widget.semanticLabel == '体重入力キャラクター',
        ),
        matching: find.byType(RawImage),
      ),
    );
    expect(characterRenderImages.single.image, isNotNull);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('../docs/screenshots/home-screen-high-touch.png'),
    );
  });

  testWidgets(
    'saves weight and shows celebration after tapping high-touch character',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _FakeWeightRepository();

      await _pumpHomeScreen(tester, repository: repository);
      await tester.enterText(find.byType(TextFormField), '77.7');
      tester.binding.focusManager.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('ハイタッチ'));
      await tester.pumpAndSettle();

      expect(repository.savedWeights, [77.7]);
      expect(
        _assetNameForSemanticLabel(tester, '体重入力キャラクター'),
        'assets/images/character_celebration.png',
      );
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('../docs/screenshots/home-screen-celebration.png'),
      );

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(ReportScreen), findsOneWidget);
    },
  );

  testWidgets('renders report screen with high-touch character', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(922, 1706));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final entries = [
      WeightEntry(date: DateTime(2026, 6, 30), weightKg: 86.3),
      WeightEntry(date: DateTime(2026, 6, 29), weightKg: 86.7),
      WeightEntry(date: DateTime(2026, 6, 28), weightKg: 85.8),
      WeightEntry(date: DateTime(2026, 6, 27), weightKg: 87.3),
      WeightEntry(date: DateTime(2026, 6, 26), weightKg: 87.3),
      WeightEntry(date: DateTime(2026, 6, 25), weightKg: 87.3),
      WeightEntry(date: DateTime(2026, 6, 24), weightKg: 87.3),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weightEntriesProvider.overrideWith((ref) => Stream.value(entries)),
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
          home: const ReportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('レポート応援キャラクター'), findsOneWidget);
    expect(
      _assetNameForSemanticLabel(tester, 'レポート応援キャラクター'),
      'assets/images/character_report.png',
    );
    expect(find.text('本日の\n体重'), findsOneWidget);
    expect(find.text('直近７日間の体重記録'), findsOneWidget);
    expect(find.text('視聴者さん♪'), findsOneWidget);
    expect(find.textContaining('毎日の積み重ねが'), findsNothing);
    expect(find.textContaining('目標まであと'), findsOneWidget);
    expect(find.textContaining('※7日平均は'), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
    await expectLater(
      find.byType(ReportScreen),
      matchesGoldenFile('../docs/screenshots/report-screen.png'),
    );
  });

  testWidgets('shows an error dialog when high-touch save fails', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeWeightRepository(saveError: StateError('保存失敗'));

    await _pumpHomeScreen(tester, repository: repository);
    await tester.enterText(find.byType(TextFormField), '77.7');
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('ハイタッチ'));
    await tester.pumpAndSettle();

    expect(find.text('エラーが発生しました'), findsOneWidget);
    expect(find.textContaining('保存失敗'), findsOneWidget);
    expect(find.textContaining('発生箇所:'), findsOneWidget);
    expect(repository.savedWeights, isEmpty);
  });

  testWidgets('limits weight input to numeric values, one decimal, and 999.9', (
    tester,
  ) async {
    await _pumpHomeScreen(tester);
    final fieldFinder = find.byType(TextFormField);

    await tester.enterText(fieldFinder, '123.4');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '123.4'), findsOneWidget);

    await tester.enterText(fieldFinder, '123.45');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '123.4'), findsOneWidget);

    await tester.enterText(fieldFinder, '1000');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '123.4'), findsOneWidget);

    await tester.enterText(fieldFinder, 'abc');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '123.4'), findsOneWidget);

    await tester.enterText(fieldFinder, '.5');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '123.4'), findsOneWidget);
  });
}

Future<void> _verifyRequiredImageAssets() async {
  for (final assetPath in _requiredImageAssets) {
    final bytes = await rootBundle.load(assetPath);
    if (bytes.lengthInBytes == 0) {
      throw StateError('Required golden image asset is empty: $assetPath');
    }
  }
}
