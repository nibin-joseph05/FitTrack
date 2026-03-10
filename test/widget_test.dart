import 'package:flutter_test/flutter_test.dart';
import 'package:fit_track/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: Since main() has Hive init, we'd normally need to mock it,
    // but for a simple smoke test on FitTrackApp we can pump it.
    await tester.pumpWidget(const FitTrackApp());

    // Verify that splash screen text is present.
    expect(find.text('FitTrack'), findsOneWidget);
    expect(find.text('Track your gains. Own your progress.'), findsOneWidget);
  });
}
