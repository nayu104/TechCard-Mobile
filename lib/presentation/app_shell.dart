import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/contacts_page.dart';
import 'pages/exchange_page.dart';
import 'pages/my_card_page.dart';
import 'pages/settings_page.dart';
import 'providers/global_providers.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override

  /// ボトムナビゲーションと各ページを保持するシェルを構築。
  /// IndexedStackで状態を保持しつつタブ切替を実現。
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          MyCardPage(),
          ContactsPage(),
          ExchangePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        /// タブ選択時にcurrentIndexを更新。
        onDestinationSelected: (value) {
          ref.read(bottomNavProvider.notifier).state = value;
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.badge_outlined), label: '名刺'),
          NavigationDestination(
              icon: Icon(Icons.view_list_outlined), label: '一覧'),
          NavigationDestination(
              icon: Icon(Icons.qr_code_2_outlined), label: '交換'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: '設定'),
        ],
      ),
    );
  }
}
