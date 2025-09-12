import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/contacts_page.dart';
import 'pages/exchange_page.dart';
import 'pages/my_card_page.dart';
import 'pages/settings_page.dart';
import 'pages/sign_in.dart';
import 'providers/providers.dart';

/// アプリのシェル。ボトムナビゲーションとタブごとのページ（IndexedStack）を束ねる。
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  // // 端末の軽いバイブ例（必要なら有効化）
  // void vibrate() => HapticFeedback.lightImpact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechCard'),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          authState.when(
            data: (user) {
              if (user == null) {
                // 未ログイン
                return Tooltip(
                  message: 'ログイン',
                  child: IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SignInPage(),
                        ),
                      );
                    },
                  ),
                );
              } else {
                // ログイン済み時：ユーザー名表示
                return _buildWelcomeMessage(ref, user.uid);
              }
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
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
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: const Color(0xFFFF8F00), // 橙（ダークでも視認性高）
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
            selectedIconTheme: const IconThemeData(color: Color(0xFFFF8F00)),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          splashFactory: NoSplash.splashFactory, // タップ時フラッシュ無効
          highlightColor: Colors.transparent, // ハイライト無効
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
              icon: Icon(Icons.credit_card_outlined),
              activeIcon: Icon(Icons.credit_card),
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
