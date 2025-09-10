import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import 'data_providers.dart';
import 'usecase_providers.dart';

/// 交換サービス: 入力検証→Remote directory参照→追加→結果メッセージ。
class ExchangeService {
  ExchangeService(this.ref);
  final Ref ref;

  /// ユーザーIDを元に名刺を交換（登録）する。
  /// 入力検証→リモート検索→追加→結果メッセージを返す。
  Future<({bool added, String message})> exchangeByUserId(String userId) async {
    if (!isValidUserId(userId)) {
      return (added: false, message: 'ユーザーIDが不正です');
    }
    final remote = ref.read(remoteDirectoryRepositoryProvider);
    final remoteContact = await remote.fetchByUserId(userId);
    final contact = remoteContact ?? _buildContactFromUserId(userId);
    final addUc = await ref.read(addContactUseCaseProvider.future);
    final ok = await addUc(contact);
    return (added: ok, message: ok ? '名刺を追加しました' : 'すでに追加済みです');
  }

  /// GitHub名を元に名刺を交換（登録）する。
  /// 入力検証→リモート検索→追加→結果メッセージを返す。
  Future<({bool added, String message})> exchangeByGithubUsername(
      String githubUsername) async {
    if (githubUsername.trim().isEmpty) {
      return (added: false, message: 'GitHub名を入力してください');
    }
    final remote = ref.read(remoteDirectoryRepositoryProvider);
    final remoteContact =
        await remote.fetchByGithubUsername(githubUsername.trim());
    if (remoteContact == null) {
      return (added: false, message: 'GitHub名「$githubUsername」のユーザーが見つかりません');
    }
    final addUc = await ref.read(addContactUseCaseProvider.future);
    final ok = await addUc(remoteContact);
    return (added: ok, message: ok ? '名刺を追加しました' : 'すでに追加済みです');
  }

  /// リモート未取得時のフォールバック名刺を生成。
  Contact _buildContactFromUserId(String userId) {
    if (userId == 'demo') {
      return Contact(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'エラー花子',
        userId: 'error_hanako',
        bio: 'エラー花子です',
        skills: const [
          'エラー',
        ],
      );
    }
    return Contact(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: userId,
      userId: userId,
      bio: '',
    );
  }
}

final exchangeServiceProvider = Provider<ExchangeService>(ExchangeService.new);
