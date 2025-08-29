import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state_providers.dart';
import 'data_providers.dart';

const _themeKey = 'theme_mode';

ThemeMode _parseTheme(String? v) {
  switch (v) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String _themeToString(ThemeMode m) {
  switch (m) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

/// 永続化されたThemeModeを読み出して反映する。
final themeLoaderProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final str = prefs.getString(_themeKey);
  if (str != null) {
    ref.read(themeModeProvider.notifier).state = _parseTheme(str);
  }
});

/// ThemeModeを文字列化して永続保存する。
Future<void> persistTheme(WidgetRef ref, ThemeMode mode) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  await prefs.setString(_themeKey, _themeToString(mode));
}
