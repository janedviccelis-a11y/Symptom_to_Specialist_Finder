import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:symptomm/app_state.dart';
import 'package:symptomm/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'dark_mode': false});
    darkMode.value = false;
  });

  testWidgets('app loads and opens the symptom flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('About Mediora'));
    await tester.pumpAndSettle();

    expect(find.text('About Mediora'), findsOneWidget);
    expect(find.textContaining('Mediora helps you decide'), findsOneWidget);
  });

  testWidgets('home shows the app logo and toggles the color theme',
      (WidgetTester tester) async {
    darkMode.value = false;
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final logo = tester.widget<Image>(find.byType(Image).first);
    expect(
        (logo.image as AssetImage).assetName, 'assets/images/mediora_logo.png');
    expect(tester.takeException(), isNull);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light);

    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pump();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);
    expect(find.byTooltip('Switch to light mode'), findsOneWidget);
  });

  testWidgets('home control returns to the first page without a back header',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Go back'), findsNothing);
    expect(find.byTooltip('Home'), findsOneWidget);

    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();

    expect(find.text('MEDIORA'), findsOneWidget);
  });

  testWidgets('selected body area filters the symptom list',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();
    expect(find.text('Where does it hurt?'), findsOneWidget);
    expect(find.text('Or choose an area'), findsNothing);

    tester
        .widget<ActionChip>(
          find.widgetWithText(ActionChip, 'Abdomen & Digestion'),
        )
        .onPressed!
        .call();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();
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

  testWidgets('selecting a body area shows matching symptoms',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start New Symptom Search'));
    await tester.pumpAndSettle();

    tester
        .widget<ActionChip>(
          find.widgetWithText(ActionChip, 'Chest & Breathing'),
        )
        .onPressed!
        .call();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Chest Pain'), findsOneWidget);
    expect(find.text('Headache'), findsNothing);
  });
}
