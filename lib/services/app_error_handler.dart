import 'dart:async';

import 'package:flutter/material.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class AppErrorHandler {
  const AppErrorHandler._();

  static void report(Object error, StackTrace stackTrace) {
    FlutterError.presentError(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );
    unawaited(showErrorDialog(error, stackTrace));
  }

  static Future<void> showErrorDialog(
    Object error, [
    StackTrace? stackTrace,
  ]) async {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    await showErrorDialogForContext(context, error, stackTrace);
  }

  static Future<void> showErrorDialogForContext(
    BuildContext context,
    Object error, [
    StackTrace? stackTrace,
  ]) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラーが発生しました'),
        content: SingleChildScrollView(
          child: Text(_formatErrorMessage(error, stackTrace)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static String _formatErrorMessage(Object error, StackTrace? stackTrace) {
    final location = _firstAppStackFrame(stackTrace);
    if (location == null) return error.toString();

    return '${error.toString()}\n\n発生箇所: $location';
  }

  static String? _firstAppStackFrame(StackTrace? stackTrace) {
    if (stackTrace == null) return null;

    for (final line in stackTrace.toString().split('\n')) {
      final uriMatch = RegExp(
        r'\((file://[^:]+):(\d+):(\d+)\)',
      ).firstMatch(line);
      if (uriMatch != null) {
        final path = Uri.parse(uriMatch.group(1)!).toFilePath();
        final normalizedPath = path.replaceAll('\\', '/');
        final libIndex = normalizedPath.indexOf('/lib/');
        final testIndex = normalizedPath.indexOf('/test/');
        final relativePath = libIndex >= 0
            ? normalizedPath.substring(libIndex + 1)
            : testIndex >= 0
            ? normalizedPath.substring(testIndex + 1)
            : normalizedPath;
        return '$relativePath:${uriMatch.group(2)}:${uriMatch.group(3)}';
      }

      final packageMatch = RegExp(
        r'(package:weight_report_app/[^\s)]+):(\d+):(\d+)',
      ).firstMatch(line);
      if (packageMatch != null) {
        return '${packageMatch.group(1)}:${packageMatch.group(2)}:${packageMatch.group(3)}';
      }
    }

    return null;
  }
}
