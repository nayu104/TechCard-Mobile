import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../infrastructure/services/auth_service.dart';
import '../../infrastructure/repositories/user_repository_imp.dart';
import '../../domain/entities/user_profile.dart';

// 認証サービスのProvider - シングルトン提供
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 認証状態の監視Provider - リアルタイム更新
// 用途: ログイン/ログアウト時の自動画面切り替え
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// ユーザーリポジトリのProvider - シングルトン提供
final userRepositoryProvider =
    Provider<UserRepositoryImpl>((ref) => UserRepositoryImpl());

// 現在のユーザープロフィール取得Provider
// 動作: 認証状態変化 → プロフィール自動再取得
final currentUserProfileProvider = FutureProvider<MyProfile?>((ref) async {
  // 認証状態を監視
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) {
        return null; // 未ログイン時はnull返却
      }

      final repo = ref.watch(userRepositoryProvider);
      return await repo.getUserProfile(user.uid);
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
