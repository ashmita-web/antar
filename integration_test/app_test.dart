import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:antar/app.dart';
import 'package:antar/core/providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full flow: Welcome → Official → Budget → Citizen', (tester) async {
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

    // Welcome screen
    expect(find.text('ANTAR'), findsWidgets);
    expect(find.text('Official — MP Console'), findsOneWidget);
    expect(find.text('Citizen — Awaaz'), findsOneWidget);

    // Select official mode
    await tester.tap(find.text('Official — MP Console'));
    await tester.pumpAndSettle();

    // Dashboard should show
    expect(find.text('MP Console'), findsOneWidget);

    // Navigate to Budget tab
    final budgetIcon = find.byIcon(Icons.account_balance_wallet_outlined);
    if (budgetIcon.evaluate().isNotEmpty) {
      await tester.tap(budgetIcon.first);
      await tester.pumpAndSettle();
      expect(find.text('Budget'), findsWidgets);
    }

    // Go to settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    // Switch to citizen mode
    await tester.tap(find.text('Switch Mode'));
    await tester.pumpAndSettle();

    // Should show Awaaz
    expect(find.text('Awaaz'), findsOneWidget);

    // Navigate to Report tab
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(find.text('What does your community need?'), findsOneWidget);
  });
}
