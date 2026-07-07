import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: WeightReportApp()));
}

class WeightReportApp extends StatelessWidget {
  const WeightReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEF5EA8)),
        fontFamily: 'Noto Sans JP',
        scaffoldBackgroundColor: const Color(0xFFFFF7FB),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
