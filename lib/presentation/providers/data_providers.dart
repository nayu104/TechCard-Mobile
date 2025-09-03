import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:techcard_mobile/domain/repositories.dart';
import 'package:techcard_mobile/infrastructure/datasources/local_data_source.dart';
import 'package:techcard_mobile/infrastructure/remotes/firebase_remote_directory.dart';
import 'package:techcard_mobile/infrastructure/repositories/repositories_impl.dart';

/// SharedPreferencesのインスタンスを提供。
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// JSONの読み書きを行うローカルデータソース。
final localDataSourceProvider = FutureProvider<LocalDataSource>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalDataSource(prefs);
});

/// プロフィールの取得/保存を担うRepository。
final profileRepositoryProvider =
    FutureProvider<ProfileRepository>((ref) async {
  final local = await ref.watch(localDataSourceProvider.future);
  return ProfileRepositoryImpl(local);
});

/// 連絡先一覧の取得/追加を担うRepository。
final contactsRepositoryProvider =
    FutureProvider<ContactsRepository>((ref) async {
  final local = await ref.watch(localDataSourceProvider.future);
  return ContactsRepositoryImpl(local);
});

/// 活動ログの取得/追記を担うRepository。
final activityRepositoryProvider =
    FutureProvider<ActivityRepository>((ref) async {
  final local = await ref.watch(localDataSourceProvider.future);
  return ActivityRepositoryImpl(local);
});

/// Firestoreインスタンスの提供。
final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// リモート名刺ディレクトリのRepository（ユーザー検索用）。
final remoteDirectoryRepositoryProvider = Provider<RemoteDirectoryRepository>(
    (ref) => FirebaseRemoteDirectory(ref.watch(firebaseFirestoreProvider)));
