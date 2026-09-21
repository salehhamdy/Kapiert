import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KapiertApp());

    // Verify the app renders the Lookup tab title
    expect(find.text('Kapiert'), findsOneWidget);
    expect(find.text('German Article Trainer'), findsOneWidget);
  });
}

