import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';

import 'core/providers.dart';
import 'router.dart';
import 'theme/theme.dart';

class AntarApp extends ConsumerWidget {
  const AntarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ANTAR',
      debugShowCheckedModeBanner: false,
      theme: antarLightTheme(),
      darkTheme: antarDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
    );
  }
}
