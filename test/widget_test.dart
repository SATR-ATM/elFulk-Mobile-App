import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Smoke test widget renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('ElFulk test'),
        ),
      ),
    );

    expect(find.text('ElFulk test'), findsOneWidget);
  });
}
