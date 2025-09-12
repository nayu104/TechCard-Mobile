import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // FirebaseAuthのインスタンスを取得
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 現在ログイン中のユーザー取得
  // 戻り値: User（ログイン済み） / null（未ログイン）
  User? get currentUser => _auth.currentUser;

  // 認証状態の変化をStreamでリアルタイム監視
  // 用途: ログイン/ログアウト時の自動画面遷移
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // ログアウト実行
  // 効果: 認証状態をクリア、authStateChangesが検知して画面遷移
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // ユーザーID取得
  // 戻り値: UID文字列 / null（未ログイン時）
  String? get currentUid => _auth.currentUser?.uid;
}

extension GithubSignIn on AuthService {
  Future<UserCredential> signInWithGithub() async {
    try {
      final provider = GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email')
        ..setCustomParameters({'allow_signup': 'false'});

      if (kIsWeb) {
        return await _auth.signInWithPopup(provider);
      } else {
        return await _auth.signInWithProvider(provider);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 既存ユーザーに GitHub をリンクする（匿名含む）
  Future<UserCredential> linkWithGithub() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'リンクするにはログインが必要です',
      );
    }
    try {
      final provider = GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email')
        ..setCustomParameters({'allow_signup': 'false'});

      if (kIsWeb) {
        // Web: Popup でリンク
        // ignore: invalid_use_of_visible_for_testing_member
        // ignore: invalid_use_of_protected_member
        return await user.linkWithPopup(provider);
      } else {
        return await user.linkWithProvider(provider);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        // 既にリンク済み: 追加情報を得るため再認証
        final provider = GithubAuthProvider()
          ..addScope('read:user')
          ..addScope('user:email')
          ..setCustomParameters({'allow_signup': 'false'});
        return await user.reauthenticateWithProvider(provider);
      }
      rethrow;
    }
  }
}
