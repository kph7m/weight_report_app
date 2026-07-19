import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/weight_providers.dart';
import 'screens/home_screen.dart';
import 'services/app_error_handler.dart';
import 'services/prompt_repository.dart';
import 'theme/app_theme.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppErrorHandler.showErrorDialog(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      AppErrorHandler.report(error, stackTrace);
      return true;
    };
    final promptRepository = PromptRepository();
    runApp(
      ProviderScope(
        overrides: [
          promptRepositoryProvider.overrideWithValue(promptRepository),
        ],
        child: const WeightReportApp(),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await promptRepository.getAiCommentPrompt();
      } on Object catch (error, stackTrace) {
        AppErrorHandler.showErrorDialog(error, stackTrace);
      }
    });
  }, AppErrorHandler.report);
}

class WeightReportApp extends StatelessWidget {
  const WeightReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Weight Report',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
