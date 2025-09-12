import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Maps thrown exceptions to short, user-friendly Japanese messages.
String mapExceptionToMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'ユーザーが見つかりませんでした';
      case 'wrong-password':
        return 'パスワードが正しくありません';
      case 'account-exists-with-different-credential':
        return '別の方法で登録済みのアカウントです';
      case 'credential-already-in-use':
      case 'provider-already-linked':
        return 'すでに連携済みです';
      case 'popup-closed-by-user':
        return '認証がキャンセルされました';
      default:
        return '認証に失敗しました（${error.code}）';
    }
  }

  if (error is FirebaseException) {
    // Firestore/Storageなど共通
    if (error.code == 'permission-denied') {
      return '権限がありません';
    }
    if (error.code == 'unavailable') {
      return 'ネットワークに接続できません';
    }
    if (error.code == 'already-exists') {
      return 'すでに存在しています';
    }
    return '処理に失敗しました（${error.code}）';
  }

  final msg = error.toString();
  // Firestore Transaction: "all reads before writes" の典型
  if (msg.contains('Transactions require all reads to be executed before all writes')) {
    return '一時的な処理エラーが発生しました。もう一度お試しください';
  }
  if (msg.contains('PERMISSION_DENIED')) {
    return '権限がありません';
  }
  if (msg.contains('network') || msg.contains('timeout')) {
    return 'ネットワークに接続できません';
  }
  return 'エラーが発生しました';
}


