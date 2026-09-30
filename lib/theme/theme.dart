import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

ThemeData antarLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AntarColors.primary,
    brightness: Brightness.light,
  );
  return _buildTheme(colorScheme);
}

ThemeData antarDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AntarColors.primary,
    brightness: Brightness.dark,
  );
  return _buildTheme(colorScheme);
}

ThemeData _buildTheme(ColorScheme colorScheme) {
  final textTheme = GoogleFonts.notoSansTextTheme(
    ThemeData(colorScheme: colorScheme).textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme.copyWith(
      headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AntarRadius.card),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AntarSpacing.md,
        vertical: AntarSpacing.sm,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AntarRadius.chip),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AntarRadius.button),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AntarRadius.button),
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AntarRadius.sheet),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AntarRadius.chip),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      labelType: NavigationRailLabelType.selected,
    ),
  );
}
