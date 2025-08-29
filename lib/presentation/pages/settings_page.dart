// 目的: 設定画面。主要要素=テーマ切替、プロフィール詳細編集。
// watch方針: themeModeはwatchで反映、保存はイベントでpersistTheme。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models.dart';
import '../providers/providers.dart';
import '../widgets/pills.dart';
import '../widgets/settings/theme_selector.dart';
import '../widgets/settings/profile_form.dart';

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
              return ProfileForm(
                name: name,
                userId: userId,
                bio: bio,
                company: company,
                role: role,
                github: github,
                onSave: (updated) async {
                  if (!isValidUserId(updated.userId) ||
                      updated.name.isEmpty ||
                      updated.bio.isEmpty) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ユーザーIDが不正です')));
                    return;
                  }
                  try {
                    final uc =
                        await ref.read(updateProfileUseCaseProvider.future);
                    await uc(updated);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('保存しました')));
                    ref.invalidate(profileProvider);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('保存に失敗しました')));
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
}
