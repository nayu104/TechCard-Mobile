import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/contacts_page.dart';
import 'pages/exchange_page.dart';
import 'pages/my_card_page.dart';
import 'pages/settings_page.dart';
import 'pages/sign_in.dart';
import 'providers/providers.dart';
import 'providers/auth_providers.dart';
import 'providers/usecase_providers.dart';

//import 'dart:io'; // プラットフォーム判定用

/// アプリのシェル。
/// ボトムナビゲーションとタブごとのページ（IndexedStack）を束ねる。
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  //ボタンを押すと振動するようにする関数
  // void vibrate() {
  //   if (Platform.isIOS) {
  //     HapticFeedback.selectionClick(); // iOS: 自然なクリック感
  //   } else if (Platform.isAndroid) {
  //     HapticFeedback.lightImpact(); // Android: 確実に動作する軽いバイブ
  //   } else {
  //     HapticFeedback.lightImpact(); // その他: デフォルト
  //   }
  // }

  @override

  /// ボトムナビゲーションと各ページを保持するシェルを構築。
  /// IndexedStackで状態を保持しつつタブ切替を実現。
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechCard'),
        actions: [
          // 認証状態に応じて表示を切り替え
          authState.when(
            data: (user) {
              if (user == null) {
                // 未ログイン時：ログインボタンを表示
                return Tooltip(
                  message: 'ログイン',
                  child: TextButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text('ログイン'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const SignInPage()),
                      );
                    },
                  ),
                );
              } else {
                // ログイン済み時：ユーザー名を表示
                return _buildWelcomeMessage(ref, user.uid);
              }
            },
            //SizedBox.shrink() は“幅0×高さ0”の箱＝画面上は何も出さないウィジェット
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          )
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          MyCardPage(),
          ContactsPage(),
          ExchangePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
          splashFactory: NoSplash.splashFactory, // タップ時のフラッシュ効果を無効化
          highlightColor: Colors.transparent, // ハイライト効果を透明に
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            ref.read(bottomNavProvider.notifier).state = value;
            // vibrate();
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.badge_outlined),
              activeIcon: Icon(Icons.badge),
              label: '名刺',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_list_outlined),
              activeIcon: Icon(Icons.view_list),
              label: '一覧',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2_outlined),
              activeIcon: Icon(Icons.qr_code_2),
              label: '交換',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }

  // ログイン済み時のウェルカムメッセージ
  Widget _buildWelcomeMessage(WidgetRef ref, String uid) {
    final profileAsync = ref.watch(firebaseProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final userName = profile?.name ?? 'ゲスト';
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Center(
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
