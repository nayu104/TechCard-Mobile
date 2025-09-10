// 目的: 設定画面。主要要素=テーマ切替、プロフィール詳細編集。
// watch方針: themeModeはwatchで反映、保存はイベントでpersistTheme。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models.dart';
import '../../infrastructure/datasources/local_data_source.dart';
import '../providers/providers.dart';
import '../widgets/common/qr_dialog.dart';
import '../widgets/settings/theme_selector.dart';
import '../../config/links.dart' as links;

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
                    // ゲストログイン
                    SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final name = await _promptForName(context);
                        if (name == null || name.trim().isEmpty) return;
                        try {
                          final action = ref.read(guestLoginWithNameProvider);
                          await action(name.trim());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ゲストとして「$name」でログインしました')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ゲストログインに失敗しました: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.person_add_alt),
                      label: const Text('ゲストとしてログイン'),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (profile?.userId.isNotEmpty ?? false)
                              ? () async {
                                  final clean = normalizeUserId(profile!.userId);
                                  await Clipboard.setData(
                                      ClipboardData(text: clean));
                                  await Fluttertoast.showToast(msg: 'コピーしました');
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
                                  final clean = normalizeUserId(profile!.userId);
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
                      final prefs = await ref.read(sharedPreferencesProvider.future);
                      await prefs.remove(LocalKeys.activities);
                      // 活動ログの再取得
                      ref.invalidate(activitiesProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('アクティビティ履歴を削除しました')),
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
          const SizedBox(height: 16),
          // プライバシーとセキュリティ
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('プライバシーとセキュリティ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.public),
                    title: const Text('公開データの範囲'),
                    subtitle: const Text('public_profilesに保存される項目と公開範囲の説明'),
                    onTap: () => _showPrivacyInfo(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.rule_folder),
                    title: const Text('セキュリティルールの概要'),
                    subtitle: const Text('users_v01/public_profiles の権限ルール'),
                    onTap: () => _showRulesInfo(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 利用規約/プライバシーポリシー
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ポリシー',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('利用規約を読む'),
                    onTap: () => _launchUrl(links.termsUrl),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('プライバシーポリシーを読む'),
                    onTap: () => _launchUrl(links.privacyPolicyUrl),
                  ),
                ],
              ),
            ),
          ),
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
                      ListTile(
                        leading: const Icon(Icons.book),
                        title: const Text('ライセンス'),
                        onTap: () => showLicensePage(context: context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('リポジトリ'),
                        onTap: () => _launchUrl(links.repositoryUrl),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        ),
      ),
    );
  }

  Future<String?> _promptForName(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('表示名を入力'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '例: 山田太郎'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('公開データの範囲'),
        content: const Text(
            'public_profiles には以下が保存され、誰でも閲覧できます:\n\n'
            '- userId, name, avatar, message, skills, github, ownerUid, updatedAt\n\n'
            '書き込みは本人のみに制限され、ドキュメントIDと userId の一致が求められます。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('閉じる')),
        ],
      ),
    );
  }

  void _showRulesInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('セキュリティルールの概要'),
        content: const Text(
            'users_v01/{uid}: 本人のみ read/write 可。\n'
            'public_profiles/{userId}: read は全体公開、write は ownerUid が本人かつ doc ID と userId が一致する場合のみ許可。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('閉じる')),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await Fluttertoast.showToast(msg: 'URLを開けませんでした');
    }
  }
}
