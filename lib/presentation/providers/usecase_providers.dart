import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:techcard_mobile/domain/models.dart';
import 'package:techcard_mobile/domain/use_cases.dart';
import 'package:techcard_mobile/presentation/providers/auth_providers.dart';
import 'package:techcard_mobile/presentation/providers/data_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// プロフィール取得UseCaseの提供。
final getProfileUseCaseProvider =
    FutureProvider<GetProfileUseCase>((ref) async {
  final repo = await ref.watch(profileRepositoryProvider.future);
  return GetProfileUseCase(repo);
});

// 交換履歴（直近50件）: 自分が承認した交換の位置情報を含む
final exchangesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = ref.watch(authStateProvider);
  return await auth.when(
    data: (user) async {
      if (user == null) return [];
      final snap = await FirebaseFirestore.instance
          .collection('exchanges')
          .where('ownerUid', isEqualTo: user.uid)
          .orderBy('exchangedAt', descending: true)
          .limit(50)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    },
    loading: () async => [],
    error: (_, __) async => [],
  );
});

// Map表示用に、現在の名刺一覧に存在する相手のみを抽出
final mapExchangesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = ref.watch(authStateProvider);
  return await auth.when(
    data: (user) async {
      if (user == null) return [];
      try {
        final snap = await FirebaseFirestore.instance
            .collection('exchanges')
            .where('ownerUid', isEqualTo: user.uid)
            .orderBy('exchangedAt', descending: true)
            .limit(100)
            .get();
        final list = snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .where((m) => m['location'] != null)
            .toList();
        return list;
      } on Exception {
        return [];
      }
    },
    loading: () async => [],
    error: (_, __) async => [],
  );
});

/// 今月の交換回数（Firestoreの exchanges から集計）
final monthlyExchangeCountProvider = FutureProvider<int>((ref) async {
  final auth = ref.watch(authStateProvider);
  return await auth.when(
    data: (user) async {
      if (user == null) return 0;
      try {
        final now = DateTime.now();
        final threshold = now.subtract(const Duration(days: 30));
        final snap = await FirebaseFirestore.instance
            .collection('exchanges')
            .where('ownerUid', isEqualTo: user.uid)
            .where('exchangedAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(threshold))
            .get();
        return snap.size;
      } on Exception {
        return 0;
      }
    },
    loading: () async => 0,
    error: (_, __) async => 0,
  );
});

// 交換申請（受信）件数
final friendRequestsCountProvider = Provider<int>((ref) {
  final async = ref.watch(friendRequestsProvider);
  return async.maybeWhen(data: (list) => list.length, orElse: () => 0);
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
  final profileRepo = await ref.watch(profileRepositoryProvider.future);
  return AddContactUseCase(contactsRepo, activityRepo, profileRepo);
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
/// ローカルファースト版（既存）
final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  final uc = await ref.watch(getContactsUseCaseProvider.future);
  return uc();
});

/// Firebase版名刺一覧状態
/// 背景: ゲストログイン後、Firebaseに保存された名刺一覧を表示する必要がある
/// 意図: 認証状態に基づいてFirebaseから名刺一覧を取得し、一覧画面で表示
final firebaseContactsProvider = FutureProvider<List<Contact>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Future.value([]);
      }
      // Firebaseから名刺一覧を取得
      final userRepo = ref.watch(userRepositoryProvider);
      return userRepo.getContacts(user.uid);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 特定ユーザーのプロフィール差分更新
/// 背景: ユーザーがメッセージを更新した際、そのユーザーのみを更新したい
/// 意図: ピンポイントで特定のプロフィールのみを取得して差分更新
final FutureProviderFamily<Contact?, String> contactUpdateProvider =
    FutureProvider.family<Contact?, String>((ref, String userId) {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getContactUpdate(userId);
});

/// 活動ログ一覧状態。
final activitiesProvider = FutureProvider<List<ActivityItem>>((ref) async {
  // Firestore exchanges から直近3日・最大15件を「交換しました！」として構築
  final auth = ref.watch(authStateProvider);
  return await auth.when(
    data: (user) async {
      if (user == null) return [];
      try {
        final since = DateTime.now().subtract(const Duration(days: 3));
        final snap = await FirebaseFirestore.instance
            .collection('exchanges')
            .where('ownerUid', isEqualTo: user.uid)
            .where('exchangedAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(since))
            .orderBy('exchangedAt', descending: true)
            .limit(15)
            .get();

        final items = <ActivityItem>[];
        for (final d in snap.docs) {
          final data = d.data();
          final peerName = (data['peerName'] as String?) ?? '';
          final exchangedAt = (data['exchangedAt'] as Timestamp?)?.toDate() ??
              (data['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now();
          items.add(ActivityItem(
            id: d.id,
            title: '${peerName.isNotEmpty ? peerName : '相手'} と交換しました！',
            kind: ActivityKind.exchange,
            occurredAt: exchangedAt,
          ));
        }
        return items;
      } on Exception {
        return [];
      }
    },
    loading: () async => [],
    error: (_, __) async => [],
  );
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
final firebaseProfileProvider = FutureProvider<MyProfile?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Future.value();
      }
      final userRepo = ref.watch(userRepositoryProvider);
      return userRepo.getUserProfile(user.uid); // Firebaseから取得
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
    final user = authState.when(
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

// 活動ログのリフレッシュ状態管理
final isRefreshingActivitiesProvider = StateProvider<bool>((ref) => false);

// 交換申請（受信）一覧
// 認証ユーザーの受信申請を取得（pending のみ）
final friendRequestsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return [];
      final repo = ref.watch(userRepositoryProvider);
      return repo.getIncomingRequests(user.uid);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// 申請承認アクション
final acceptFriendRequestActionProvider =
    Provider<Future<void> Function(String)>((ref) {
  return (String requestId) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.acceptFriendRequest(requestId);
    // 活動ログを更新（今月の交換/活動履歴のため）
    try {
      final activityRepo = await ref.read(activityRepositoryProvider.future);
      await activityRepo.addActivity(ActivityItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '名刺を交換しました',
        kind: ActivityKind.exchange,
        occurredAt: DateTime.now(),
      ));
      ref.invalidate(activitiesProvider);
    } catch (_) {}
    // 一覧更新
    ref.invalidate(friendRequestsProvider);
    ref.invalidate(firebaseContactsProvider);
  };
});

// 申請却下アクション
final declineFriendRequestActionProvider =
    Provider<Future<void> Function(String)>((ref) {
  return (String requestId) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.updateFriendRequestStatus(requestId, 'declined');
    ref.invalidate(friendRequestsProvider);
  };
});

// 申請キャンセル（送信側がキャンセルする場合に利用可）
final cancelFriendRequestActionProvider =
    Provider<Future<void> Function(String)>((ref) {
  return (String requestId) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.updateFriendRequestStatus(requestId, 'canceled');
    ref.invalidate(friendRequestsProvider);
  };
});

// 名刺削除アクション
final deleteContactActionProvider =
    Provider<Future<void> Function(String)>((ref) {
  return (String contactUserId) async {
    final auth = ref.read(authStateProvider);
    final user = auth.when(
      data: (u) => u,
      loading: () => null,
      error: (_, __) => null,
    );
    if (user == null) return;
    final repo = ref.read(userRepositoryProvider);
    await repo.deleteContact(ownerUid: user.uid, contactUserId: contactUserId);
    ref.invalidate(firebaseContactsProvider);
  };
});
