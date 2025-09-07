import 'package:firebase_auth/firebase_auth.dart';

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
