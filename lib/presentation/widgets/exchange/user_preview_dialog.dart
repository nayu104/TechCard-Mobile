import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../domain/models.dart';
import '../../providers/providers.dart';

/// ユーザー検索結果のプレビュー画面
/// ゲームのフレンド検索のような確認画面
class UserPreviewDialog extends ConsumerWidget {
  const UserPreviewDialog({
    super.key,
    required this.contact,
    required this.onAdd,
  });

  final Contact contact;
  final Future<void> Function() onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アバター
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: (contact.avatarUrl?.isNotEmpty ?? false)
                  ? ClipOval(
                      child: Image.network(
                        contact.avatarUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 16),

            // ユーザー名
            Text(
              contact.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // ユーザーID
            Text(
              '@${contact.userId}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 自己紹介
            if (contact.bio.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Text(
                  contact.bio,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // スキル
            if (contact.skills.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: contact.skills
                    .map<Widget>((skill) => Chip(
                          label: Text(skill),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 8),

            // ボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await onAdd();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('申請を送る'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ユーザー検索結果を表示するダイアログ
class UserSearchResultDialog extends ConsumerWidget {
  const UserSearchResultDialog({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Contact?>(
      future: _searchUser(ref, userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('ユーザーを検索中...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '検索に失敗しました',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'エラー: ${snapshot.error}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            ),
          );
        }

        final contact = snapshot.data;
        if (contact == null) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_off,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ユーザーが見つかりません',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@$userId',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            ),
          );
        }

        return UserPreviewDialog(
          contact: contact,
          onAdd: () => _addContact(ref, contact),
        );
      },
    );
  }

  Future<Contact?> _searchUser(WidgetRef ref, String userId) async {
    try {
      // 入力を正規化（@や不可視文字の除去など）
      final normalizedUserId = normalizeUserId(userId);
      print('UserSearchResultDialog: Searching for userId (normalized): $normalizedUserId (raw: $userId)');
      final remote = ref.read(remoteDirectoryRepositoryProvider);
      final result = await remote.fetchByUserId(normalizedUserId);
      print(
          'UserSearchResultDialog: Search result: ${result != null ? "Found" : "Not found"}');
      return result;
    } catch (e) {
      print('UserSearchResultDialog: Search error: $e');
      throw Exception('ユーザー検索に失敗しました: $e');
    }
  }

  Future<void> _addContact(WidgetRef ref, Contact contact) async {
    // 互換のため名称は維持するが、挙動は「交換申請の送信」に変更
    try {
      final uid = ref.read(currentFirebaseUidProvider);
      if (uid == null || uid.isEmpty) {
        await Fluttertoast.showToast(msg: 'ログインが必要です');
        return;
      }

      // 送信者のuserId（自分）
      final myProfile = await ref.read(firebaseProfileProvider.future);
      final senderUserId = myProfile?.userId;
      if (senderUserId == null || senderUserId.isEmpty) {
        await Fluttertoast.showToast(msg: '自分のユーザーIDが未設定です');
        return;
      }

      // 受信者のownerUidを取得（public_profilesから）
      final userRepo = ref.read(userRepositoryProvider);
      final receiverPublic = await userRepo.getPublicProfile(contact.userId);
      if (receiverPublic == null) {
        await Fluttertoast.showToast(msg: '相手の公開プロフィールが見つかりません');
        return;
      }

      final receiverUid = receiverPublic.ownerUid;
      final receiverUserId = receiverPublic.userId;

      await userRepo.sendFriendRequest(
        senderUid: uid,
        senderUserId: senderUserId,
        receiverUid: receiverUid,
        receiverUserId: receiverUserId,
      );

      await Fluttertoast.showToast(msg: '交換申請を送信しました');
    } catch (e) {
      print('UserPreviewDialog: 交換申請送信エラー: $e');
      await Fluttertoast.showToast(msg: '申請の送信に失敗しました');
    }
  }
}
