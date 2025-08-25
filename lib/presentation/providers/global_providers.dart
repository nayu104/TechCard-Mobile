// 役割: アプリ全体のDIコンテナ。DataSource/Repository/UseCase/状態(モード)を提供。
// watch/read/select方針: UIはwatch、イベント時はread、パフォーマンス要件でselectを使用し再ビルド最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/firebase_remote_directory.dart';
import '../../data/local_data_source.dart';
import '../../data/repositories_impl.dart';
import '../../domain/models.dart';
import '../../domain/repositories.dart';
import '../../domain/use_cases.dart';

// UI層からwatch。副作用なし。書き込みはController/イベント経由。
/// 現在のボトムタブインデックス（0:MyCard/1:Contacts/2:Exchange/3:Settings）。
final bottomNavProvider = StateProvider<int>((ref) => 0);

/// マイ名刺の編集モードON/OFF。
final isEditingProvider = StateProvider<bool>((ref) => false);

/// 現在のThemeMode。永続ストレージと同期。
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Data source & repositories
// DataSource: 端末KV保存。アプリ再起動間で永続。
/// SharedPreferencesのインスタンスを提供。
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// JSONの読み書きを行うローカルデータソース。
final localDataSourceProvider = FutureProvider<LocalDataSource>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalDataSource(prefs);
});

// Repository: 失敗時は例外→Failure変換はUseCase側で吸収想定（現状例外シンプル）。
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

// Firebase
/// Firestoreインスタンスの提供。
final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// リモート名刺ディレクトリのRepository（ユーザー検索用）。
final remoteDirectoryRepositoryProvider = Provider<RemoteDirectoryRepository>(
    (ref) => FirebaseRemoteDirectory(ref.watch(firebaseFirestoreProvider)));

// Use cases
// UseCase: 入出力と主失敗（ArgumentError等）を定義。副作用はRepository経由。
/// プロフィール取得UseCaseの提供。
final getProfileUseCaseProvider =
    FutureProvider<GetProfileUseCase>((ref) async {
  final repo = await ref.watch(profileRepositoryProvider.future);
  return GetProfileUseCase(repo);
});

/// プロフィール更新UseCaseの提供。
final updateProfileUseCaseProvider =
    FutureProvider<UpdateProfileUseCase>((ref) async {
  final repo = await ref.watch(profileRepositoryProvider.future);
  final activity = await ref.watch(activityRepositoryProvider.future);
  return UpdateProfileUseCase(repo, activity);
});

/// 連絡先一覧取得UseCaseの提供。
final getContactsUseCaseProvider =
    FutureProvider<GetContactsUseCase>((ref) async {
  final repo = await ref.watch(contactsRepositoryProvider.future);
  return GetContactsUseCase(repo);
});

/// 連絡先追加UseCaseの提供。
final addContactUseCaseProvider =
    FutureProvider<AddContactUseCase>((ref) async {
  final contactsRepo = await ref.watch(contactsRepositoryProvider.future);
  final activityRepo = await ref.watch(activityRepositoryProvider.future);
  return AddContactUseCase(contactsRepo, activityRepo);
});

/// 活動ログ一覧取得UseCaseの提供。
final getActivitiesUseCaseProvider =
    FutureProvider<GetActivitiesUseCase>((ref) async {
  final repo = await ref.watch(activityRepositoryProvider.future);
  return GetActivitiesUseCase(repo);
});

// Async states
// 状態遷移: Loading → Data(null可) → Error。再試行はinvalidateでトリガ。
/// プロフィール状態。nullは未設定を示す。
final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final uc = await ref.watch(getProfileUseCaseProvider.future);
  return uc();
});

/// 連絡先一覧状態。
final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  final uc = await ref.watch(getContactsUseCaseProvider.future);
  return uc();
});

/// 活動ログ一覧状態。
final activitiesProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final uc = await ref.watch(getActivitiesUseCaseProvider.future);
  return uc();
});

// Exchange service
// 交換サービス: 入力検証→Remote directory参照→追加→結果メッセージ。
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

  /// リモート未取得時のフォールバック名刺を生成。
  Contact _buildContactFromUserId(String userId) {
    if (userId == 'demo') {
      return Contact(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Alice Johnson',
        userId: 'alice_backend',
        bio:
            'バックエンドエンジニアとしてNode.jsとPythonでAPI開発をしています。データベース設計からクラウドインフラまで幅広く担当しています。',
        skills: const [
          'Node.js',
          'Python',
          'PostgreSQL',
          'Docker',
          'AWS',
          'GraphQL'
        ],
        company: 'StartupCorp',
        role: 'Backend Engineer',
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

final exchangeServiceProvider =
    Provider<ExchangeService>((ref) => ExchangeService(ref));

// Theme persistence
const _themeKey = 'theme_mode';
ThemeMode _parseTheme(String? v) {
  switch (v) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String _themeToString(ThemeMode m) {
  switch (m) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

// テーマ復元: 起動時に永続値を読み取り、ThemeModeを設定。
/// 永続化されたThemeModeを読み出して反映する。
final themeLoaderProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final str = prefs.getString(_themeKey);
  if (str != null) {
    ref.read(themeModeProvider.notifier).state = _parseTheme(str);
  }
});

/// ThemeModeを文字列化して永続保存する。
Future<void> persistTheme(WidgetRef ref, ThemeMode mode) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  await prefs.setString(_themeKey, _themeToString(mode));
}
