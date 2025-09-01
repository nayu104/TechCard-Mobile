import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:techcard_mobile/domain/models.dart';
import 'package:techcard_mobile/domain/use_cases.dart';
import 'package:techcard_mobile/presentation/providers/data_providers.dart';

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
