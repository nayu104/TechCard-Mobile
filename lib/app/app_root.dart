// 役割: アプリのルートWidget。Theme/Routerの設定と、Riverpodとの連携を担う。
// 責務分離: Theme(ここ) / Router(app_shell.dart) / DI(global_providers.dart)。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/app_shell.dart';
import '../presentation/providers/global_providers.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override

  /// MaterialAppとテーマ設定を構築し、AppShellをホームに据える。
  /// themeLoaderProviderをwatchして永続テーマを初期反映。
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // 起動時にテーマ設定を永続化ストレージから反映。
    ref.watch(themeLoaderProvider);
    return MaterialApp(
      title: 'TechCard Mobile',
      themeMode: themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const AppShell(),
    );
  }
}

final _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFf59e0b),
    surface: Color(0xFFFFFFFF),
  ),
  scaffoldBackgroundColor: const Color(0xFFfafafa),
  cardTheme: const CardThemeData(
    color: Color(0xFFFFFFFF),
    elevation: 1,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
);

final _darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFfbbf24),
    surface: Color(0xFF1e293b),
  ),
  scaffoldBackgroundColor: const Color(0xFF0f172a),
  cardTheme: const CardThemeData(
    color: Color(0xFF1e293b),
    elevation: 1,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
);
