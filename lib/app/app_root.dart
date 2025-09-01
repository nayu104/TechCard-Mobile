// 役割: アプリのルートWidget。Theme/Routerの設定と、Riverpodとの連携を担う。
// 責務分離: Theme(ここ) / Router(app_shell.dart) / DI(global_providers.dart)。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/app_shell.dart';
import '../presentation/providers/providers.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override

  /// MaterialAppとテーマ設定を構築し、AppShellをホームに据える。
  /// themeLoaderProviderをwatchして永続テーマを初期反映。
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // 起動時にテーマ設定を永続化ストレージから反映。
    ref.watch(themeLoaderProvider);
    // MaterialAppの中でテーマ/ルーティング/ホームを束ねる。
    // - themeMode: 端末/手動で切替
    // - theme/darkTheme: 共通トークン（ColorSchemeやCardの角丸など）を定義
    // もしボトムバーの選択ピル色（indicator）を消す/変更したい場合は、
    // _lightTheme/_darkTheme を copyWith して NavigationBarThemeData を上書きする。
    return MaterialApp(
      title: 'TechCard Mobile',
      themeMode: themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const AppShell(),
    );
  }
}

// Lightテーマ定義。
// 方針: Material3を有効化しつつ、ブランドカラー(primary)をアンバー系に統一。
// 影/角丸/サーフェスの色はアプリ全体で一貫させる。
final _lightTheme = ThemeData(
  useMaterial3: true, // Material 3デザインシステムを有効化
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFf59e0b), // アプリ全体のプライマリカラー（アンバー系）
  ),
  navigationBarTheme: const NavigationBarThemeData(
    indicatorColor: Colors.transparent, // ボトムナビゲーションの選択ピル背景色（透明）
  ),
  scaffoldBackgroundColor: const Color(0xFFfafafa), // アプリ全体の背景色（薄いグレー）
  cardTheme: const CardThemeData(
    color: Color(0xFFFFFFFF), // カードの背景色（白）
    elevation: 1, // カードの影の深さ
    surfaceTintColor: Colors.transparent, // カードの表面色調整（透明）
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16))), // カードの角丸（16px）
  ),
);

// Darkテーマ定義。
// 方針: Lightと同じトークンを踏襲しつつ、読みやすさを優先してコントラストを確保。
// 必要に応じて NavigationBar のインジケータやラベル/アイコンのコントラストは
// NavigationBarThemeData で上書きできる（例: indicatorColorを透明にする等）。
final _darkTheme = ThemeData(
  useMaterial3: true, // Material 3デザインシステムを有効化
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFfbbf24), // アプリ全体のプライマリカラー（明るいアンバー系）
    surface: Color(0xFF1e293b), // 表面色（ダークグレー）
  ),
  navigationBarTheme: const NavigationBarThemeData(
    indicatorColor: Color.fromARGB(169, 0, 0, 0), // ボトムナビゲーションの選択ピル背景色（半透明黒）
    height: 60, // 高さを小さくする
  ),
  scaffoldBackgroundColor: const Color(0xFF0f172a), // アプリ全体の背景色（濃いダークグレー）
  cardTheme: const CardThemeData(
    color: Color(0xFF1e293b), // カードの背景色（ダークグレー）
    elevation: 1, // カードの影の深さ
    surfaceTintColor: Colors.transparent, // カードの表面色調整（透明）
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16))), // カードの角丸（16px）
  ),
);
