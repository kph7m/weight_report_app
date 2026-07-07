import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_report_app/providers/weight_providers.dart';
import 'package:weight_report_app/screens/home_screen.dart';

void main() {
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
            fontFamily: 'Noto Sans JP',
            scaffoldBackgroundColor: const Color(0xFFFFF7FB),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('../docs/screenshots/home-screen.png'),
    );
  });
}
