import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../presentation/app_shell.dart';
import '../presentation/pages/sign_in.dart';
import '../presentation/providers/providers.dart';

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  @override
  void initState() {
    super.initState();
    _ensureLocationPermission();
  }

  Future<void> _ensureLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // ユーザーにサービス有効化を促すだけ（ブロックしない）
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // deniedForever の場合はアプリ内で必要時に設定画面誘導
    } catch (_) {
      // 失敗しても起動は継続
    }
  }
  @override
  Widget build(BuildContext context) {
    // ✅ 元のテーマProvider使用を復活
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    ref.watch(themeLoaderProvider);

    return MaterialApp(
      title: 'TechCard Mobile',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const AppShell();
          } else {
            return const SignInPage();
          }
        },
        loading: () {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('認証確認中...'),
                ],
              ),
            ),
          );
        },
        error: (error, _) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('認証エラー: $error'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// テーマ定義（元のコードから）
final _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFf59e0b),
  ),
  scaffoldBackgroundColor: const Color(0xFFfafafa),
  cardTheme: const CardThemeData(
    color: Color(0xFFFFFFFF),
    elevation: 1,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
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
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
);
