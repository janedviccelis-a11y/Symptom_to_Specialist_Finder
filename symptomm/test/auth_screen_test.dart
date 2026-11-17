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

  testWidgets('login screen provides guest and account creation paths',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    await tester.tap(find.text('Continue as a guest'));
    await tester.pumpAndSettle();
    expect(find.text('Start New Symptom Search'), findsOneWidget);
  });

  testWidgets('home profile action opens a guest profile prompt',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as a guest'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Guest profile'), findsOneWidget);
    expect(find.text('Log in to view and update your account details.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration shows Not match until passwords are equal',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(4), 'password-one');
    await tester.enterText(find.byType(TextFormField).at(5), 'password-two');
    await tester.pumpAndSettle();
    expect(find.text('Not match'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(5), 'password-one');
    await tester.pumpAndSettle();
    expect(find.text('Not match'), findsNothing);
  });

  testWidgets('registration form scrolls on a mobile-sized screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
