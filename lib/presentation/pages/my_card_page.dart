// 目的: 自分の名刺編集/表示。主要要素=プロフィール編集、QR表示、活動履歴。
// watch方針: プロフィールはwatch、編集ON/OFFはStateProviderで再ビルド最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:techcard_mobile/presentation/widgets/custom_text_field.dart';
import 'package:techcard_mobile/utils/responsive_text.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProfileHeaderContent(
                                  isEditing: false, // 常に表示モード
                                  controllerName: controllerName,
                                  controllerId: controllerId,
                                  displayName: profile?.name ?? '未設定',
                                  // ADDED COMMENT: 表示はusername優先（URLから抽出）。未設定は空文字。
                                  displayGithub:
                                      _extractGithubUsername(profile?.github) ??
                                          '',
                                ),
                                const SizedBox(height: 12),
                                // ひとことメッセージの表示
                                Column(
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
                                // スキルの表示
                                Wrap(
                                  children: (profile?.skills ?? [])
                                      .map((s) => SkillChip(label: s))
                                      .toList(),
                                ),
                              ]),
                        ),
                        // 編集ボタンを右上に配置
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              ref.read(isEditingProvider.notifier).state = true;
                            },
                          ),
                        ),
                      ],
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
              ),

              // 編集モード時のXレイアウト
              if (isEditing)
                GestureDetector(
                  // 垂直方向のドラッグが終了したときのイベント
                  onVerticalDragEnd: (details) {
                    // 下方向へのスワイプ速度が一定以上なら閉じる
                    if (details.primaryVelocity != null &&
                        details.primaryVelocity! > 200) {
                      ref.read(isEditingProvider.notifier).state = false;
                    }
                  },
                  child: Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.85,
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: [
                              // ドラッグハンドル
                              Container(
                                width: 40,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).dividerColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // ヘッダー
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(isEditingProvider.notifier)
                                            .state = false;
                                      },
                                      child: Text(
                                        'キャンセル',
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(
                                            context,
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'プロフィール編集',
                                      style: TextStyle(
                                        fontSize: responsiveFontSize(
                                          context,
                                          16,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await _saveProfile(
                                            ref,
                                            profile,
                                            controllerName,
                                            controllerId,
                                            controllerMessage);
                                      },
                                      child: Text(
                                        '保存',
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(
                                            context,
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(),

                              // 編集フォーム
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 名前編集
                                      CustomTextField(
                                        controller: controllerName,
                                        labelText: '名前',
                                        hintText: 'ここに入力してください',
                                      ),
                                      const SizedBox(height: 16),

                                      // GitHub編集
                                      CustomTextField(
                                        controller: controllerId,
                                        labelText: 'GitHub',
                                        hintText: 'ユーザー名またはURL',
                                        keyboardType: TextInputType.url,
                                      ),
                                      const SizedBox(height: 16),

                                      // ひとこと編集
                                      CustomTextField(
                                        controller: controllerMessage,
                                        labelText: 'ひとこと（50文字まで）',
                                        hintText: '自己紹介やメッセージを入力してください',
                                        maxLines: 3,
                                        validator: (value) {
                                          if (value != null &&
                                              value.length > 50) {
                                            return '50文字以内で入力してください';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // スキル編集
                                      // Text(
                                      //   'スキルを追加 (最大5個)',
                                      //   style: Theme.of(context)
                                      //       .textTheme
                                      //       .titleMedium
                                      //       ?.copyWith(
                                      //         fontWeight: FontWeight.bold,
                                      //         fontSize: responsiveFontSize(
                                      //           context,
                                      //           1,
                                      //         ),
                                      //       ),
                                      // ),

                                      EditableSkills(
                                        initial: profile?.skills ?? const [],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }

  // プロフィール保存メソッド
  Future<void> _saveProfile(
      WidgetRef ref,
      UserProfile? profile,
      TextEditingController controllerName,
      TextEditingController controllerId,
      TextEditingController controllerMessage) async {
    if (profile == null) return;

    final updated = UserProfile(
      avatar: profile.avatar.isNotEmpty
          ? profile.avatar
          : ((_extractGithubUsername(controllerId.text) != null)
              ? 'https://github.com/${_extractGithubUsername(controllerId.text)}.png'
              : ''),
      name: controllerName.text,
      userId: _safeUserId(profile.userId, controllerName.text),
      createdAt: profile.createdAt,
      email: profile.email,
      friendIds: profile.friendIds,
      github: _normalizeGithub(controllerId.text),
      message: controllerMessage.text,
      skills: ref.read(editingSkillsProvider),
    );

    try {
      final uc = await ref.read(updateProfileUseCaseProvider.future);
      await uc(updated);
      await Fluttertoast.showToast(msg: '保存しました');
      ref.invalidate(profileProvider);
      ref.read(editingSkillsProvider.notifier).state = const [];
      ref.read(isEditingProvider.notifier).state = false;
    } catch (e) {
      // ADDED COMMENT: 失敗時は編集モードを維持し、明確な文言で通知
      final msg =
          (e is ArgumentError) ? 'ひとことは50文字以内、ユーザーIDは英数アンダースコアのみ' : '保存に失敗しました';
      await Fluttertoast.showToast(msg: msg);
      ref.read(isEditingProvider.notifier).state = true;
    }
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
