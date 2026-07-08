import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_report_app/services/app_error_handler.dart';

void main() {
  testWidgets('shows app-wide error dialog with error details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: appNavigatorKey,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => AppErrorHandler.showErrorDialogForContext(
              context,
              StateError('全体エラー'),
              StackTrace.current,
            ),
            child: const Text('show error'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('show error'));
    await tester.pumpAndSettle();

    expect(find.text('エラーが発生しました'), findsOneWidget);
    expect(find.textContaining('全体エラー'), findsOneWidget);
    expect(find.textContaining('発生箇所:'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('エラーが発生しました'), findsNothing);
  });
}
