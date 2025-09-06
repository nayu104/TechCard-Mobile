import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:techcard_mobile/domain/models.dart';
import 'package:techcard_mobile/domain/use_cases.dart';
import 'package:techcard_mobile/presentation/providers/data_providers.dart';
import 'package:techcard_mobile/presentation/providers/auth_providers.dart';

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

/// プロフィール状態。nullは未設定を示す。
final profileProvider = FutureProvider<MyProfile?>((ref) async {
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

/// プロフィール状態。nullは未設定を示す。
/// ローカルファースト版（既存）
final localProfileProvider = FutureProvider<MyProfile?>((ref) async {
  //   Future<GetProfileUseCase>を待機してGetProfileUseCaseを取得
  final uc = await ref.watch(getProfileUseCaseProvider.future);
  //   GetProfileUseCase()を実行してMyProfile?を取得
  return uc();
});

/// Firebase版プロフィール状態
/// 背景: ゲストログイン後、Firebaseに保存されたプロフィールを表示する必要がある
/// 意図: 認証状態に基づいてFirebaseからプロフィールを取得し、MyCardで表示
final firebaseProfileProvider = FutureProvider<MyProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) {
        return null;
      }
      final userRepo = ref.watch(userRepositoryProvider);
      return await userRepo.getUserProfile(user.uid); // Firebaseから取得
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Firebase版プロフィール更新Provider
/// 背景: MyCard編集画面の保存機能をFirebase対応にする必要がある
/// 意図: Firebaseにプロフィールを保存し、ローカル版と同様の機能を提供
final firebaseUpdateProfileProvider = // 認証状態を取得（一度だけ）
    Provider<Future<void> Function(MyProfile)>((ref) {
  return (MyProfile profile) async {
    // ユーザー情報を取得
    final authState = ref.read(authStateProvider);
    final user = await authState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );
    // ログイン確認
    if (user == null) {
      throw Exception('ユーザーがログインしていません');
    }
    // Firebaseに保存
    final userRepo = ref.read(userRepositoryProvider);
    await userRepo.saveUserProfile(user.uid, profile);
  };
});
