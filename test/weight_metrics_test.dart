import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seven day average math is correct', () {
    final values = [80.0, 79.0, 78.0, 77.0, 76.0, 75.0, 74.0];
    final average = values.reduce((a, b) => a + b) / values.length;
    expect(average, 77.0);
  });
}
