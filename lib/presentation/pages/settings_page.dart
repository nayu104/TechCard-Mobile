// 目的: 設定画面。主要要素=テーマ切替、プロフィール詳細編集。
// watch方針: themeModeはwatchで反映、保存はイベントでpersistTheme。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart'; // not used

import '../../domain/models.dart';
import '../../core/error_messages.dart';
import '../../infrastructure/datasources/local_data_source.dart';
import '../providers/providers.dart';
import '../widgets/common/qr_dialog.dart';
import '../widgets/settings/theme_selector.dart';
// import '../../config/links.dart' as links; // not used

/// 設定ページ。
/// テーマ切替とプロフィール詳細編集フォームを提供する。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override

  /// 設定セクションをまとめて描画。
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(firebaseProfileProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 外観
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
                        if (v == null) return;
                        ref.read(themeModeProvider.notifier).state = v;
                        await persistTheme(ref, v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // アカウント
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('アカウント',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    // ゲストログインは非表示（要望）
                    const SizedBox(height: 8),
                    // GitHub連携は非表示（要望）
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('確認'),
                                  content: const Text('ログアウトしますか？'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('キャンセル')),
                                    FilledButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('ログアウト')),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!ok) return;
                          try {
                            final logout = ref.read(logoutActionProvider);
                            await logout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ログアウトしました')),
                              );
                            }
                          } on Exception {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ログアウトに失敗しました')),
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
            const SizedBox(height: 16),
            // プロフィール
            profileAsync.when(
              data: (profile) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('プロフィール',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('ユーザーID: @${profile?.userId ?? '未設定'}'),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: (profile != null)
                              ? () async {
                                  final newId = await _promptForUserId(
                                      context, profile.userId);
                                  if (newId == null || newId.trim().isEmpty) {
                                    return;
                                  }
                                  try {
                                    final auth = ref.read(authServiceProvider);
                                    final uid = auth.currentUid;
                                    if (uid == null) {
                                      throw Exception('ログインが必要です');
                                    }
                                    await ref
                                        .read(userRepositoryProvider)
                                        .updateUserIdAtomic(
                                          uid: uid,
                                          oldUserId: profile.userId,
                                          newUserId: newId.trim(),
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('ユーザーIDを変更しました')),
                                      );
                                    }
                                    ref.invalidate(firebaseProfileProvider);
                                  } catch (e) {
                                    final friendly = mapExceptionToMessage(e);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(friendly)),
                                      );
                                    }
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.alternate_email),
                          label: const Text('ユーザーIDを変更'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: (profile?.userId.isNotEmpty ?? false)
                                ? () async {
                                    final clean =
                                        normalizeUserId(profile!.userId);
                                    await Clipboard.setData(
                                        ClipboardData(text: clean));
                                    await Fluttertoast.showToast(
                                        msg: 'コピーしました');
                                  }
                                : null,
                            icon: const Icon(Icons.copy_outlined),
                            label: const Text('IDコピー'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: (profile?.userId.isNotEmpty ?? false)
                                ? () {
                                    final clean =
                                        normalizeUserId(profile!.userId);
                                    showDialog<void>(
                                      context: context,
                                      builder: (_) => QrDialog(
                                        data: clean,
                                        caption: '@$clean',
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.qr_code_2),
                            label: const Text('自分のQRを表示'),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // 名刺・連絡先セクションは削除（要望により）
            const SizedBox(height: 16),
            // データ管理（アクティビティ履歴の削除）
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('データ管理',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final prefs =
                            await ref.read(sharedPreferencesProvider.future);
                        await prefs.remove(LocalKeys.activities);
                        // 活動ログの再取得
                        ref.invalidate(activitiesProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('アクティビティ履歴を削除しました'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('アクティビティ履歴を削除'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // プライバシー/ポリシーのカードは削除
            const SizedBox(height: 16),
            // アプリ情報
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data != null
                    ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                    : '読み込み中...';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('アプリ情報',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('バージョン'),
                          trailing: Text(version),
                        ),
                        // ライセンス/リポジトリは非表示
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Animation "Sample Loaders" by Bobbeh (Rive Marketplace, CC BY)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 削除: ゲストログイン入力ダイアログは非表示につき未使用

  Future<String?> _promptForUserId(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ユーザーIDを変更'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '英数字・_・-（3〜30文字）'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('キャンセル')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('OK')),
        ],
      ),
    );
  }

  // 削除: プライバシー/ルールのダイアログ

  // 削除: 外部URL起動は未使用
}
