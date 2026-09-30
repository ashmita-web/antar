import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antar/app.dart';
import 'package:antar/core/providers.dart';

void main() {
  testWidgets('Welcome screen shows mode selection', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const AntarApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ANTAR'), findsOneWidget);
    expect(find.text('Citizen — Awaaz'), findsOneWidget);
    expect(find.text('Official — MP Console'), findsOneWidget);
  });

  testWidgets('Selecting official mode navigates to dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const AntarApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Official — MP Console'));
    await tester.pumpAndSettle();

    expect(find.text('MP Console'), findsOneWidget);
    expect(find.text('Constituency Overview'), findsOneWidget);
  });
}
