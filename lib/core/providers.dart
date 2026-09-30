import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'env.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override with actual SharedPreferences instance');
});

final appModeProvider = StateNotifierProvider<AppModeNotifier, AppMode?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppModeNotifier(prefs);
});

class AppModeNotifier extends StateNotifier<AppMode?> {
  AppModeNotifier(this._prefs) : super(_loadMode(_prefs));

  final SharedPreferences _prefs;

  static AppMode? _loadMode(SharedPreferences prefs) {
    final value = prefs.getString('app_mode');
    if (value == 'citizen') return AppMode.citizen;
    if (value == 'official') return AppMode.official;
    return null;
  }

  Future<void> setMode(AppMode mode) async {
    state = mode;
    await _prefs.setString('app_mode', mode.name);
  }

  Future<void> clearMode() async {
    state = null;
    await _prefs.remove('app_mode');
  }
}

final appRegionProvider =
    StateNotifierProvider<AppRegionNotifier, AppRegion>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppRegionNotifier(prefs);
});

class AppRegionNotifier extends StateNotifier<AppRegion> {
  AppRegionNotifier(this._prefs)
      : super(
          _prefs.getString('app_region') == 'brazil'
              ? AppRegion.brazil
              : AppRegion.india,
        );

  final SharedPreferences _prefs;

  Future<void> setRegion(AppRegion region) async {
    state = region;
    await _prefs.setString('app_region', region.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs)
      : super(_fromString(_prefs.getString('theme_mode')));

  final SharedPreferences _prefs;

  static ThemeMode _fromString(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setString('theme_mode', mode.name);
  }
}

final isDemoModeProvider = Provider<bool>((ref) => Env.isDemoMode);
final hasGeminiProvider = Provider<bool>((ref) => Env.hasGemini);
final hasMapsProvider = Provider<bool>((ref) => Env.hasMaps);
