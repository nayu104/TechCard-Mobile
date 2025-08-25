// 方針: I/Oの契約と失敗ケースを明確化。UI層に例外が漏れない設計を目指す。
// Failure型は簡略化のため未導入（将来Result/Failure導入可）。
// ignore_for_file: one_member_abstracts
import 'models.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(); // I/O: Local KV。失敗: デコードエラー等は例外。
  Future<void> saveProfile(UserProfile profile); // I/O: Local KV書込。失敗: 例外。
}

abstract class ContactsRepository {
  Future<List<Contact>> getContacts(); // I/O: Local KV。失敗: 例外。
  Future<bool> addContact(Contact contact); // 失敗ケース: 重複userIdはfalseを返す。
}

abstract class ActivityRepository {
  Future<List<ActivityItem>> getActivities(); // I/O: Local KV。失敗: 例外。
  Future<void> addActivity(ActivityItem item); // I/O: Local KV書込。失敗: 例外。
}

// Remote directory (Firebase) used for looking up contacts by userId
abstract class RemoteDirectoryRepository {
  Future<Contact?> fetchByUserId(String userId); // I/O: ネットワーク。未存在はnull。
}
