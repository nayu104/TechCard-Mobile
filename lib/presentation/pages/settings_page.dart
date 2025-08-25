// 目的: 設定画面。主要要素=テーマ切替、プロフィール詳細編集。
// watch方針: themeModeはwatchで反映、保存はイベントでpersistTheme。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_providers.dart';
import '../widgets/pills.dart';
import '../../domain/models.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override

  /// テーマ設定の切替とプロフィール詳細の編集フォームを描画。
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('設定'), actions: const [
        Padding(padding: EdgeInsets.only(right: 12), child: BetaPill())
      ]),
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
                    Row(children: [
                      const Text('ダークモード'),
                      const Spacer(),
                      DropdownButton<ThemeMode>(
                        value: themeMode,
                        items: const [
                          DropdownMenuItem(
                              value: ThemeMode.system, child: Text('端末設定')),
                          DropdownMenuItem(
                              value: ThemeMode.light, child: Text('ライト')),
                          DropdownMenuItem(
                              value: ThemeMode.dark, child: Text('ダーク')),
                        ],
                        onChanged: (v) async {
                          if (v == null) return;
                          ref.read(themeModeProvider.notifier).state = v;
                          await persistTheme(ref, v);
                        },
                      ),
                    ])
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
            data: (profile) {
              final name = TextEditingController(text: profile?.name ?? '');
              final userId = TextEditingController(text: profile?.userId ?? '');
              final bio = TextEditingController(text: profile?.bio ?? '');
              final company =
                  TextEditingController(text: profile?.company ?? '');
              final role = TextEditingController(text: profile?.role ?? '');
              final github =
                  TextEditingController(text: profile?.githubUsername ?? '');
              return Column(children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('基本情報',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                              controller: name,
                              decoration:
                                  const InputDecoration(labelText: '名前')),
                          TextField(
                              controller: userId,
                              decoration:
                                  const InputDecoration(labelText: 'ユーザーID')),
                          TextField(
                              controller: bio,
                              decoration:
                                  const InputDecoration(labelText: '自己紹介'),
                              maxLines: 4),
                        ]),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('職業情報',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                              controller: company,
                              decoration:
                                  const InputDecoration(labelText: '会社名')),
                          TextField(
                              controller: role,
                              decoration:
                                  const InputDecoration(labelText: '役職')),
                          TextField(
                              controller: github,
                              decoration: const InputDecoration(
                                  labelText: 'GitHubユーザー名')),
                        ]),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (!isValidUserId(userId.text) ||
                        name.text.isEmpty ||
                        bio.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ユーザーIDが不正です')));
                      return;
                    }
                    final updated = UserProfile(
                      name: name.text,
                      userId: userId.text,
                      bio: bio.text,
                      company: company.text.isEmpty ? null : company.text,
                      role: role.text.isEmpty ? null : role.text,
                      githubUsername: github.text.isEmpty ? null : github.text,
                    );
                    try {
                      final uc =
                          await ref.read(updateProfileUseCaseProvider.future);
                      await uc(updated);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('保存しました')));
                      ref.invalidate(profileProvider);
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('保存に失敗しました')));
                    }
                  },
                  child: const Text('保存'),
                )
              ]);
            },
          )
        ],
      ),
    );
  }
}
