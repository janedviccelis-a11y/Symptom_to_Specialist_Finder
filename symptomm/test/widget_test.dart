import 'package:flutter_test/flutter_test.dart';

import 'package:symptomm/main.dart';

void main() {
  testWidgets('app loads and opens the symptom flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Symptom to\nSpecialist Finder'), findsOneWidget);
    expect(find.text('Start New Symptom Search'), findsOneWidget);

    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();

    expect(find.text('Describe Your Symptoms'), findsOneWidget);
  });
}
