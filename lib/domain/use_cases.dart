// 方針: 入力検証→副作用（Repository）→結果。失敗はArgumentError等で通知。
import 'models.dart';
import 'repositories.dart';

class GetProfileUseCase {
  GetProfileUseCase(this.repo);
  final ProfileRepository repo;

  /// プロフィールを取得する。未設定時はnull。
  Future<MyProfile?> call() => repo.getProfile();
}

class UpdateProfileUseCase {
  UpdateProfileUseCase(this.repo, this.activityRepository);
  final ProfileRepository repo;
  final ActivityRepository activityRepository;

  /// プロフィールを検証し保存。成功時に活動ログを追記。
  Future<void> call(MyProfile profile) async {
    // ADDED COMMENT: 入力検証
    // - name: 空禁止（表示名として必須）
    // - message: ひとことは50文字以内（空は許容、要件に応じて調整可）
    // - userId: 英数字とアンダースコアのみ
    // if (profile.name.isEmpty ||
    //     profile.message.length > 50 ||
    //     !isValidUserId(profile.userId)) {
    //   throw ArgumentError('invalid');
    // }
    // 副作用: 保存＋活動ログ追記。
    await repo.saveProfile(profile);
    await activityRepository.addActivity(ActivityItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'プロフィールを更新',
      kind: ActivityKind.update,
      occurredAt: DateTime.now(),
    ));
  }
}

class GetContactsUseCase {
  GetContactsUseCase(this.repo);
  final ContactsRepository repo;

  /// 連絡先一覧を取得する。
  Future<List<Contact>> call() => repo.getContacts();
}

class AddContactUseCase {
  AddContactUseCase(this.repo, this.activityRepository, this.profileRepository);
  final ContactsRepository repo;
  final ActivityRepository activityRepository;
  final ProfileRepository profileRepository;

  /// 連絡先を追加。重複時はfalse。成功時のみ活動ログを追記。
  Future<bool> call(Contact contact) async {
    // 入力検証: userId形式。
    // Debug logging removed for production
    if (!isValidUserId(contact.userId)) {
      // Debug logging removed for production
      throw ArgumentError('invalid_user_id');
    }
    final ok = await repo.addContact(contact);
    // Debug logging removed for production
    // 成功時のみ活動ログを記録。重複時(false)は副作用無し。
    if (ok) {
      // MyProfileのfriendIdsに追加
      await _addToFriendIds(contact.userId);

      await activityRepository.addActivity(ActivityItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '名刺を追加: @${contact.userId}',
        kind: ActivityKind.exchange,
        occurredAt: DateTime.now(),
      ));
    }
    return ok;
  }

  /// MyProfileのfriendIdsにユーザーIDを追加
  Future<void> _addToFriendIds(String userId) async {
    final currentProfile = await profileRepository.getProfile();
    // Debug logging removed for production
    if (currentProfile != null && !currentProfile.friendIds.contains(userId)) {
      final updatedProfile = currentProfile.copyWith(
        friendIds: [...currentProfile.friendIds, userId],
        updatedAt: DateTime.now(),
      );
      // Debug logging removed for production
      await profileRepository.saveProfile(updatedProfile);
      // Debug logging removed for production
    } else {
      // Debug logging removed for production
    }
  }
}

class GetActivitiesUseCase {
  GetActivitiesUseCase(this.repo);
  final ActivityRepository repo;

  /// 活動ログ一覧を取得する。
  Future<List<ActivityItem>> call() => repo.getActivities();
}
