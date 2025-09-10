import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../infrastructure/repositories/user_repository_imp.dart';
import 'usecase_providers.dart';
import '../../infrastructure/services/auth_service.dart';

// 認証サービスのProvider - シングルトン提供
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 認証状態の監視Provider - リアルタイム更新
// 用途: ログイン/ログアウト時の自動画面切り替え
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((user) {
    // 認証状態変化を検知
    return user;
  });
});

// ユーザーリポジトリのProvider - シングルトン提供
final userRepositoryProvider =
    Provider<UserRepositoryImpl>((ref) => UserRepositoryImpl());

// 現在のユーザープロフィール取得Provider
// 動作: 認証状態変化 → プロフィール自動再取得
final currentUserProfileProvider = FutureProvider<MyProfile?>((ref) {
  // 認証状態を監視
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return null; // 未ログイン時はnull返却
      }

      final repo = ref.watch(userRepositoryProvider);
      return repo.getUserProfile(user.uid);
    },
    loading: () => null, // 認証状態取得中
    error: (_, __) => null, //  (_, __) => null, /
  );
});

// ログインアクション用Provider
// 用途: UIからの匿名ログイン実行
final loginActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final authService = ref.read(authServiceProvider);
    await authService.signInAnonymously();
    // 成功時はauthStateProviderが自動検知して画面遷移
  };
});

// ログアウトアクション用Provider
// 用途: 設定画面からのログアウト実行
final logoutActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    // 成功時はauthStateProviderが自動検知して画面遷移
  };
});

// 現在のFirebase UID取得Provider
// 用途: My名刺画面でFirebaseのUIDを表示・コピー
final currentFirebaseUidProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUid;
});

final guestLoginWithNameProvider =
    Provider<Future<void> Function(String name)>((ref) {
  return (name) async {
    final authService = ref.read(authServiceProvider);
    final userRepo = ref.read(userRepositoryProvider);

    final userCredential = await authService.signInAnonymously();
    final user = userCredential.user;

    if (user == null) {
      throw Exception('ログインに失敗しました');
    }
    // 2. ゲスト用プロフィール作成（ユニークなuserIdを生成）
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = user.uid.substring(0, 6);
    final userId = 'guest_${timestamp}_$randomSuffix';

    final profile = MyProfile(
      avatar: '',
      name: name,
      userId: userId,
      email: '',
      github: '',
      //  message: '', // デフォルトで入ってるので不要
      friendIds: [],
      skills: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 3. Firestoreに保存
    await userRepo.saveUserProfile(user.uid, profile);
    // 4. 初期ハンドル（6〜15桁の数値）を割り当て
    try {
      await userRepo.assignInitialHandle(uid: user.uid, userId: profile.userId);
    } catch (e) {
      // 競合などで失敗しても致命ではないためログのみ
    }
    // 5. プロフィール再取得
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    // Riverpod v2: invalidateで再取得
    // プロフィールを表示している各画面で最新のhandleが反映される
    // （プロバイダーのスコープによりref.invalidateが有効）
    // refをここで使えるため、そのままinvalidate
    // （Consumer側でwatchしているfirebaseProfileProviderが再読込される）
    // ignore: invalid_use_of_visible_for_testing_member
    // ignore: invalid_use_of_protected_member
    ref.invalidate(firebaseProfileProvider);

    // ゲストログイン完了
  };
});

/// GitHubでログイン
final githubLoginProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final authService = ref.read(authServiceProvider);
    final userRepo = ref.read(userRepositoryProvider);

    // 1. GitHubでサインイン
    final cred = await authService.signInWithGithub();
    final user = cred.user;
    if (user == null) {
      throw Exception('GitHubログインに失敗しました');
    }

    // 2. 既存プロフィールがなければ作成
    final existing = await userRepo.getUserProfile(user.uid);
    if (existing == null) {
      final username = cred.additionalUserInfo?.username; // GitHubユーザー名
      final displayName = user.displayName ?? username ?? 'User';
      final userId = (username != null && username.isNotEmpty)
          ? 'gh_$username'
          : 'gh_${user.uid.substring(0, 6)}';

      final profile = MyProfile(
        avatar: user.photoURL ?? '',
        name: displayName,
        userId: userId,
        email: user.email ?? '',
        github: username != null ? 'https://github.com/$username' : null,
        friendIds: [],
        skills: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userRepo.saveUserProfile(user.uid, profile);
      try {
        await userRepo.assignInitialHandle(uid: user.uid, userId: profile.userId);
      } catch (_) {}
    }

    // 3. プロフィール再取得
    ref.invalidate(firebaseProfileProvider);
  };
});
