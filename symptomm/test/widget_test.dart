import 'package:flutter_test/flutter_test.dart';

import 'package:symptomm/main.dart';

void main() {
  testWidgets('app loads and opens the symptom flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Symptom to\nSpecialist Finder'), findsOneWidget);
    expect(find.text('Start New Symptom Search'), findsOneWidget);

    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();

    expect(find.text('Describe Your Symptoms'), findsOneWidget);
  });

  testWidgets('body area picker includes digestion symptoms',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Body area'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abdomen & Digestion'));
    await tester.pumpAndSettle();
    expect(find.text('Stomach Pain'), findsOneWidget);

    await tester.tap(find.text('Stomach Pain'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsWidgets);

    await tester.tap(find.text('See specialist matches'));
    await tester.pumpAndSettle();
    expect(find.text('Your matches'), findsOneWidget);
    expect(find.text('Gastroenterology'), findsOneWidget);
    expect(find.text('View details & clinics'), findsOneWidget);

    await tester.tap(find.text('View details & clinics'));
    await tester.pumpAndSettle();
    expect(find.text('What Conditions They Handle'), findsOneWidget);
  });
}
