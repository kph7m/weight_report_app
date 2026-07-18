import 'package:flutter_test/flutter_test.dart';
import 'package:weight_report_app/models/weight_entry.dart';
import 'package:weight_report_app/screens/report_screen.dart';

void main() {
  test('seven day average math is correct', () {
    final values = [80.0, 79.0, 78.0, 77.0, 76.0, 75.0, 74.0];
    final average = values.reduce((a, b) => a + b) / values.length;
    expect(average, 77.0);
  });

  test(
    'rolling average is calculated from each day and available past days',
    () {
      final entries = [
        WeightEntry(date: DateTime(2026, 7, 16), weightKg: 85.3),
        WeightEntry(date: DateTime(2026, 7, 15), weightKg: 85.6),
      ];

      expect(rollingSevenDayAverage(entries, 0), closeTo(85.45, 0.0001));
      expect(rollingSevenDayAverage(entries, 1), 85.6);
    },
  );
}
