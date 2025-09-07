// 目的: 設定画面。主要要素=テーマ切替、プロフィール詳細編集。
// watch方針: themeModeはwatchで反映、保存はイベントでpersistTheme。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/providers.dart';
import '../widgets/settings/theme_selector.dart';

/// 設定ページ。
/// テーマ切替とプロフィール詳細編集フォームを提供する。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override

  /// テーマ設定の切替とプロフィール詳細の編集フォームを描画。
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('外観設定',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ThemeSelector(
                      value: themeMode,
                      onChanged: (v) async {
                        if (v == null) {
                          return;
                        }
                        ref.read(themeModeProvider.notifier).state = v;
                        await persistTheme(ref, v);
                      },
                    )
                  ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('アカウント',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final logout = ref.read(logoutActionProvider);
                          await logout();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ログアウトしました')),
                            );
                          }
                        } on Exception catch (e) {
                          // ログアウトエラー
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ログアウトに失敗しました: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('ログアウト'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
