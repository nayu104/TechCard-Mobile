// 方針: 例外は上位で扱う前提。重複検知はアプリ内キャッシュ(ローカル永続)で早期判定。
// 失敗→Failure変換は将来導入。再試行はUseCase/サービス側で制御。
import '../domain/models.dart';
import '../domain/repositories.dart';
import 'local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.local);
  final LocalDataSource local;

  @override

  /// プロフィールをローカルから取得。未保存時はnull。
  Future<UserProfile?> getProfile() async {
    final map = local.readJson(LocalKeys.profile);
    if (map == null) {
      return null;
    }
    return UserProfile.fromJson(map);
  }

  @override

  /// プロフィールをローカルに保存。
  Future<void> saveProfile(UserProfile profile) async {
    await local.writeJson(LocalKeys.profile, profile.toJson());
  }
}

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this.local);
  final LocalDataSource local;

  @override

  /// 連絡先一覧をローカルから取得。
  Future<List<Contact>> getContacts() async {
    final list = local.readJsonList(LocalKeys.contacts);
    return list.map(Contact.fromJson).toList();
  }

  @override

  /// 連絡先を追加。userId重複時はfalse。
  Future<bool> addContact(Contact contact) async {
    final list = await getContacts();
    final exists = list.any((c) => c.userId == contact.userId);
    if (exists) {
      return false;
    }
    final updated = [...list, contact];
    await local.writeJsonList(
        LocalKeys.contacts, updated.map((e) => e.toJson()).toList());
    return true;
  }
}

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this.local);
  final LocalDataSource local;

  @override

  /// 活動ログを末尾に追記。
  Future<void> addActivity(ActivityItem item) async {
    final list = await getActivities();
    final updated = [...list, item];
    await local.writeJsonList(
        LocalKeys.activities, updated.map((e) => e.toJson()).toList());
  }

  @override

  /// 活動ログ一覧を取得。
  Future<List<ActivityItem>> getActivities() async {
    final list = local.readJsonList(LocalKeys.activities);
    return list.map(ActivityItem.fromJson).toList();
  }
}
