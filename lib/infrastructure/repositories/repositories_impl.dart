import '../../domain/models.dart';
import '../../domain/repositories.dart';
import '../datasources/local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.local);
  final LocalDataSource local;

  @override
  Future<MyProfile?> getProfile() async {
    final map = local.readJson(LocalKeys.profile);
    if (map == null) {
      return null;
    }
    return MyProfile.fromJson(map);
  }

  @override
  Future<void> saveProfile(MyProfile profile) async {
    await local.writeJson(LocalKeys.profile, profile.toJson());
  }
}

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this.local);
  final LocalDataSource local;

  @override
  Future<List<Contact>> getContacts() async {
    final list = local.readJsonList(LocalKeys.contacts);
    return list.map(Contact.fromJson).toList();
  }

  @override
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
  Future<void> addActivity(ActivityItem item) async {
    final list = await getActivities();
    final updated = [...list, item];
    await local.writeJsonList(
        LocalKeys.activities, updated.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<ActivityItem>> getActivities() async {
    final list = local.readJsonList(LocalKeys.activities);
    return list.map(ActivityItem.fromJson).toList();
  }
}
