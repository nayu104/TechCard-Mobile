// 目的: 自分の名刺編集/表示。主要要素=プロフィール編集、QR表示、活動履歴。
// watch方針: プロフィールはwatch、編集ON/OFFはStateProviderで再ビルド最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/providers.dart';
import '../widgets/my_card/activities_list.dart';
import '../widgets/my_card/actions_row.dart';
import '../widgets/my_card/profile_header_card.dart';
import '../widgets/my_card/stat_card.dart';
import '../widgets/pills.dart';
import '../../domain/models.dart';
import '../widgets/skills/editable_skills.dart';
import '../providers/skills/editing_skills_provider.dart';

class MyCardPage extends ConsumerWidget {
  const MyCardPage({super.key});

  @override

  /// プロフィールの閲覧/編集UIとQR表示、最近の活動リストを描画する。
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(isEditingProvider);
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイ名刺'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: BetaPill())
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました')),
        data: (profile) {
          final controllerName =
              TextEditingController(text: profile?.name ?? '');
          final controllerId =
              TextEditingController(text: profile?.userId ?? '');
          final controllerBio = TextEditingController(text: profile?.bio ?? '');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(isEditing ? '編集ON' : '編集OFF'),
                  Switch(
                    value: isEditing,
                    onChanged: (v) =>
                        ref.read(isEditingProvider.notifier).state = v,
                  )
                ],
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeaderContent(
                          isEditing: isEditing,
                          controllerName: controllerName,
                          controllerId: controllerId,
                          displayName: profile?.name ?? '未設定',
                          displayUserId: profile?.userId ?? 'handle',
                          displayRole: profile?.role ??
                              'Frontend Engineer at Tech Company',
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.08),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.local_cafe_outlined, size: 16),
                                SizedBox(width: 6),
                                Text('ここにGithubアカウントの名前')
                              ]),
                        ),
                        const SizedBox(height: 12),
                        isEditing
                            ? TextField(
                                controller: controllerBio,
                                maxLines: 5,
                                decoration:
                                    const InputDecoration(labelText: '自己紹介'),
                              )
                            : Text(profile?.bio ?? ''),
                        const SizedBox(height: 12),
                        // レイアウト意図: 技術タグはWrapで改行し、タップしやすい余白を確保。
                        isEditing
                            ? EditableSkills(
                                initial: profile?.skills ?? const [])
                            : Wrap(
                                children: (profile?.skills ??
                                        [
                                          'React',
                                          'TypeScript',
                                          'Next.js',
                                          'Tailwind CSS'
                                        ])
                                    .map((s) => SkillChip(label: s))
                                    .toList()),
                      ]),
                ),
              ),
              const SizedBox(height: 12),
              ActionsRow(
                handleText: profile?.userId ?? controllerId.text,
                readHandle: () => profile?.userId ?? controllerId.text,
              ),
              const SizedBox(height: 12),
              Row(children: const [
                Expanded(child: StatCard(title: 'つながり', value: '4')),
                SizedBox(width: 12),
                Expanded(child: StatCard(title: '今月の交換', value: '3')),
              ]),
              const SizedBox(height: 12),
              const Text('最近の活動',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const ActivitiesList(),
              const SizedBox(height: 24),
              if (isEditing)
                ElevatedButton(
                  onPressed: () async {
                    final updated = UserProfile(
                      name: controllerName.text,
                      userId: controllerId.text,
                      bio: controllerBio.text,
                      skills: ref.read(editingSkillsProvider),
                    );
                    try {
                      final uc =
                          await ref.read(updateProfileUseCaseProvider.future);
                      await uc(updated);
                      await Fluttertoast.showToast(msg: '保存しました');
                      ref.invalidate(profileProvider);
                      ref.read(editingSkillsProvider.notifier).state = const [];
                    } on Exception {
                      await Fluttertoast.showToast(msg: '保存に失敗しました');
                    }
                  },
                  child: const Text('保存'),
                ),
            ],
          );
        },
      ),
    );
  }
}

// 内部クラスを分離しました（StatCard/ActivitiesList）。
