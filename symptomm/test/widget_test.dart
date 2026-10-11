import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:symptomm/main.dart';

void main() {
  testWidgets('app loads and opens the symptom flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MEDIORA'), findsOneWidget);
    expect(find.text('Start New Symptom Search'), findsOneWidget);
    expect(find.text('Explore'), findsNothing);
    expect(find.text('Recent searches'), findsNothing);
    expect(find.text('Specialty library'), findsNothing);
    expect(find.text('About this app'), findsNothing);
    expect(find.byTooltip('About Mediora'), findsOneWidget);

    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();

    expect(find.text('Describe Your Symptoms'), findsOneWidget);
  });

  testWidgets('about page is opened from the home icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('About Mediora'));
    await tester.pumpAndSettle();

    expect(find.text('About Mediora'), findsOneWidget);
    expect(find.textContaining('Mediora helps you decide'), findsOneWidget);
  });

  testWidgets('symptom selection shows symptoms only for selected body area',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();
    expect(find.text('Where does it hurt?'), findsOneWidget);
    expect(find.text('Or choose an area'), findsNothing);

    await tester.tap(find.byTooltip('Abdomen & Digestion'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Stomach Pain'),
      180,
      scrollable: find.descendant(
        of: find.byType(ListView).first,
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Stomach Pain'), findsOneWidget);
    expect(find.text('Headache'), findsNothing);

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

  testWidgets('tapping a body map region shows its symptoms',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Chest & Breathing'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Chest Pain'), findsOneWidget);
    expect(find.text('Headache'), findsNothing);
  });
}
