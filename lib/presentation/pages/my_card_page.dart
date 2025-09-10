// 目的: 自分の名刺編集/表示。主要要素=プロフィール編集、QR表示、活動履歴。
// watch方針: プロフィールはwatch、編集ON/OFFはStateProviderで再ビルド最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:techcard_mobile/presentation/widgets/custom_text_field.dart';
import 'package:techcard_mobile/utils/responsive_text.dart';

import '../../domain/models.dart';
import '../providers/providers.dart';
import '../providers/skills/editing_skills_provider.dart';
import '../widgets/my_card/actions_row.dart';
import '../widgets/my_card/activities_list.dart';
import '../widgets/my_card/profile_header_card.dart';
import '../widgets/my_card/stat_card.dart';
import '../widgets/my_card/exchange_map_banner.dart';
import '../widgets/pills.dart';
import '../widgets/skills/editable_skills.dart';

/// マイ名刺ページ。
/// プロフィールの編集/表示、QR表示、活動ログの一覧を提供する。
class MyCardPage extends ConsumerWidget {
  const MyCardPage({super.key});

  @override

  /// プロフィールの閲覧/編集UIとQR表示、最近の活動リストを描画する。
  Widget build(BuildContext context, WidgetRef ref) {
    // 目的: 自分の名刺編集/表示。主要要素=プロフィール編集、QR表示、活動履歴。
    // watch方針: プロフィールはwatch、編集ON/OFFはStateProviderで再ビルド最小化。

    final isEditing = ref.watch(isEditingProvider);
    final profileAsync = ref.watch(firebaseProfileProvider);
    // 統計用: 名刺数（つながり）と今月の交換回数
    final contactsAsync = ref.watch(firebaseContactsProvider);
    final activitiesAsync = ref.watch(activitiesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('読み込みに失敗しました')),
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
                                  // ADDED COMMENT: 表示はusername優先（URLから抽出）。
                                  // 未設定は空文字。
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
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text(
                              '編集',
                              style: TextStyle(
                                fontSize: responsiveFontSize(context, 12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                    // 公開プロフィールの userId を表示/コピー（Firebase AuthのUIDではない）
                    handleText: profile?.userId ?? '',
                    readHandle: () => profile?.userId ?? '',
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: StatCard(
                        title: 'つながり',
                        value: contactsAsync.maybeWhen(
                          data: (list) => list.length.toString(),
                          orElse: () => '0',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: '今月の交換',
                        value: activitiesAsync.maybeWhen(
                          data: (list) {
                            final now = DateTime.now();
                            final count = list.where((a) {
                              final dt = a.occurredAt;
                              final sameMonth = dt.year == now.year && dt.month == now.month;
                              return sameMonth && a.kind == ActivityKind.exchange;
                            }).length;
                            return count.toString();
                          },
                          orElse: () => '0',
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // 交換マップバナー（タップで展開して地図を表示）
                  const ExchangeMapBanner(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('最近の活動',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Consumer(
                        builder: (context, ref, child) {
                          final isRefreshing =
                              ref.watch(isRefreshingActivitiesProvider);
                          return GestureDetector(
                            onTap: isRefreshing
                                ? null
                                : () async {
                                    // ローディング状態を開始
                                    ref
                                        .read(isRefreshingActivitiesProvider
                                            .notifier)
                                        .state = true;
                                    try {
                                      // 活動ログプロバイダーを無効化して再取得
                                      ref.invalidate(activitiesProvider);
                                      // プロバイダーの完了を待つ
                                      await ref.read(activitiesProvider.future);
                                    } on Exception {
                                      // エラーハンドリング（必要に応じてユーザーに通知）
                                    } finally {
                                      // ローディング状態を終了
                                      ref
                                          .read(isRefreshingActivitiesProvider
                                              .notifier)
                                          .state = false;
                                    }
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isRefreshing
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1)
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isRefreshing
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).dividerColor,
                                ),
                              ),
                              child: AnimatedRotation(
                                turns: isRefreshing ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 1000),
                                child: isRefreshing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 地図ベースの交換履歴表示（テキストベースの活動履歴を置き換え）
                  const Text('交換履歴マップ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('過去の名刺交換を地図上で確認できます',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 12),
                ],
              ),

              // 編集モード時のXレイアウト
              if (isEditing)
                GestureDetector(
                  // 垂直方向のドラッグが終了したときのイベント
                  onVerticalDragEnd: (details) {
                    // 下方向へのスワイプ速度が一定以上なら閉じる
                    final velocity = details.primaryVelocity;
                    if (velocity != null && velocity > 200) {
                      ref.read(isEditingProvider.notifier).state = false;
                    }
                  },
                  child: Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.3),
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
                                        labelText: '名前(8文字まで)',
                                        hintText: 'ここに入力してください',
                                        maxLength: 8,
                                      ),
                                      const SizedBox(height: 16),

                                      // GitHub編集
                                      CustomTextField(
                                        controller: controllerId,
                                        labelText: 'テストGitHubあとでけす',
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
      MyProfile? profile,
      TextEditingController controllerName,
      TextEditingController controllerId,
      TextEditingController controllerMessage) async {
    if (profile == null) {
      return;
    }

    // プロフィール更新
    final updated = MyProfile(
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
      updatedAt: DateTime.now(), // 更新日時を現在に設定
    );

    try {
      final saveFunction = ref.read(firebaseUpdateProfileProvider);
      await saveFunction(updated);
      await Fluttertoast.showToast(msg: '保存しました');
      ref.invalidate(firebaseProfileProvider);
      ref.read(editingSkillsProvider.notifier).state = const [];
      ref.read(isEditingProvider.notifier).state = false;
    } on Exception catch (e) {
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
/// - 受理: フルURL(https://github.com/username) または ユーザー名単体
/// - 返却: username（空/不正はnull）
// ADDED COMMENT: URL/username どちらでも受け取り、usernameのみを返す（null安全）
String? _extractGithubUsername(String? urlOrUsername) {
  final input = (urlOrUsername ?? '').trim();
  if (input.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(input);
  if (uri != null && uri.host.contains('github.com')) {
    final seg = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    if (seg.isNotEmpty) {
      return seg.first;
    }
    return null;
  }
  // username だけ渡されたケース
  return input;
}

// ADDED COMMENT: GitHub入力（URL/username）を保存用のURLへ正規化
String? _normalizeGithub(String input) {
  final githubUsername = _extractGithubUsername(input);
  if (githubUsername == null || githubUsername.isEmpty) {
    return null;
  }
  return 'https://github.com/$githubUsername';
}

// ADDED COMMENT: userIdの安全生成（ローカル用途）
// - 既存が有効ならそのまま
// - それ以外はnameから英数_に正規化、全滅ならタイムスタンプID
String _safeUserId(String? current, String name) {
  // ADDED COMMENT: 英数字とアンダースコアのみ許可するユーザーIDの判定用正規表現
  final userIdRegex = RegExp(r'^[A-Za-z0-9_]+$');
  if (current != null && userIdRegex.hasMatch(current)) {
    return current;
  }
  final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  return slug.isNotEmpty
      ? slug
      : 'user_${DateTime.now().millisecondsSinceEpoch}';
}
