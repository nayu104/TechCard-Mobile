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

/// マイ名刺ページ。
/// プロフィールの編集/表示、QR表示、活動ログの一覧を提供する。
class MyCardPage extends ConsumerWidget {
  const MyCardPage({super.key});

  @override

  /// プロフィールの閲覧/編集UIとQR表示、最近の活動リストを描画する。
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(isEditingProvider);
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました')),
        data: (profile) {
          final controllerName =
              TextEditingController(text: profile?.name ?? '');
          final controllerId =
              TextEditingController(text: profile?.github ?? '');
          final controllerMessage =
              TextEditingController(text: profile?.message ?? '');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(isEditing ? '編集ON' : '編集OFF'),
                  Switch(
                    value: isEditing,
                    onChanged: (v) async {
                      // ADDED COMMENT: 編集OFFへ切替時に自動保存。ON時はモードのみ更新。
                      if (v) {
                        ref.read(isEditingProvider.notifier).state = true;
                        return;
                      }
                      // OFFにするタイミングで保存を実行
                      final updated = UserProfile(
                        avatar: profile?.avatar ??
                            ((_extractGithubUsername(controllerId.text) != null)
                                ? 'https://github.com/${_extractGithubUsername(controllerId.text)}.png'
                                : ''),
                        name: controllerName.text,
                        userId:
                            _safeUserId(profile?.userId, controllerName.text),
                        createdAt: profile?.createdAt ?? DateTime.now(),
                        email: profile?.email ?? '',
                        friendIds: profile?.friendIds ?? const [],
                        github: _normalizeGithub(controllerId.text),
                        message: controllerMessage.text,
                        skills: ref.read(editingSkillsProvider),
                      );
                      try {
                        final uc =
                            await ref.read(updateProfileUseCaseProvider.future);
                        await uc(updated);
                        await Fluttertoast.showToast(msg: '保存しました');
                        ref.invalidate(profileProvider);
                        ref.read(editingSkillsProvider.notifier).state =
                            const [];
                        ref.read(isEditingProvider.notifier).state = false;
                      } catch (e) {
                        // ADDED COMMENT: 失敗時は編集モードを維持し、明確な文言で通知
                        final msg = (e is ArgumentError)
                            ? 'ひとことは50文字以内、ユーザーIDは英数アンダースコアのみ'
                            : '保存に失敗しました';
                        await Fluttertoast.showToast(msg: msg);
                        ref.read(isEditingProvider.notifier).state = true;
                      }
                    },
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
                          // ADDED COMMENT: 表示はusername優先（URLから抽出）。未設定は空文字。
                          displayGithub:
                              _extractGithubUsername(profile?.github) ?? '',
                        ),
                        const SizedBox(height: 12),
                        // ADDED COMMENT: ひとことメッセージ（編集時=TextField / 表示時=見出し+本文 or 未設定）
                        isEditing
                            ? TextField(
                                // ADDED COMMENT: ひとことは message にマッピング
                                controller: controllerMessage,
                                maxLines: 3,
                                maxLength: 50,
                                decoration: const InputDecoration(
                                    labelText: 'ひとこと（50文字まで）'),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('ひとことメッセージ：',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    (profile != null &&
                                            profile.message.isNotEmpty)
                                        ? profile.message
                                        : '未設定',
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 12),
                        // レイアウト意図: 技術タグはWrapで改行し、タップしやすい余白を確保。
                        isEditing
                            ? EditableSkills(
                                initial: profile?.skills ?? const [])
                            : Wrap(
                                children: (profile?.skills ?? [])
                                    .map((s) => SkillChip(label: s))
                                    .toList(),
                              ),
                      ]),
                ),
              ),
              const SizedBox(height: 12),
              ActionsRow(
                // ADDED COMMENT: ハンドルは GitHub ではなく userId を表示/コピー
                handleText: profile?.userId ?? '',
                readHandle: () => profile?.userId ?? '',
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
            ],
          );
        },
      ),
    );
  }
}

// 内部クラスを分離しました（StatCard/ActivitiesList）。
/// 入力文字列からGitHubユーザー名を抽出するユーティリティ。
/// - 受理: フルURL(https://github.com/<username>) または ユーザー名単体
/// - 返却: username（空/不正はnull）
// ADDED COMMENT: URL/username どちらでも受け取り、usernameのみを返す（null安全）
String? _extractGithubUsername(String? urlOrUsername) {
  final input = (urlOrUsername ?? '').trim();
  if (input.isEmpty) return null;
  final uri = Uri.tryParse(input);
  if (uri != null && uri.host.contains('github.com')) {
    final seg = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    if (seg.isNotEmpty) return seg.first;
    return null;
  }
  // username だけ渡されたケース
  return input;
}

// ADDED COMMENT: GitHub入力（URL/username）を保存用のURLへ正規化
String? _normalizeGithub(String input) {
  final githubUsername = _extractGithubUsername(input);
  if (githubUsername == null || githubUsername.isEmpty) return null;
  return 'https://github.com/$githubUsername';
}

// ADDED COMMENT: userIdの安全生成（ローカル用途）
// - 既存が有効ならそのまま
// - それ以外はnameから英数_に正規化、全滅ならタイムスタンプID
String _safeUserId(String? current, String name) {
  // ADDED COMMENT: 英数字とアンダースコアのみ許可するユーザーIDの判定用正規表現
  final userIdRegex = RegExp(r'^[A-Za-z0-9_]+$');
  if (current != null && userIdRegex.hasMatch(current)) return current;
  final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  return slug.isNotEmpty
      ? slug
      : 'user_${DateTime.now().millisecondsSinceEpoch}';
}
