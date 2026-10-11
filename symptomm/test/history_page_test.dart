import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptomm/pages/history_page.dart';

void main() {
  testWidgets('clear history updates the page immediately', (tester) async {
    SharedPreferences.setMockInitialValues({
      'history': [
        '{"t":"2026-10-11T10:00:00.000","s":["Headache"]}',
      ],
    });
    await tester.pumpWidget(
      const MaterialApp(home: HistoryPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Headache'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear history'));
    await tester.pump();

    expect(find.textContaining('No searches yet.'), findsOneWidget);
    expect(find.text('Headache'), findsNothing);

    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('history'), isNull);
  });
}
