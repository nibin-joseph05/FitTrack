import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test passes', (WidgetTester tester) async {
    // A simple test ensuring the test runner works.
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: Text('FitTrack'))));
    expect(find.text('FitTrack'), findsOneWidget);
  });
}
