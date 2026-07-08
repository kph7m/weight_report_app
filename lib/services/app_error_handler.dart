import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class AppErrorHandler {
  const AppErrorHandler._();

  static void report(Object error, StackTrace stackTrace) {
    FlutterError.presentError(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );
    unawaited(showErrorDialog(error));
  }

  static Future<void> showErrorDialog(Object error) async {
    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラーが発生しました'),
        content: SingleChildScrollView(child: Text(error.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
