import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/public_profile.dart';

// ユーザープロフィールのFirestore操作を担当
// 役割: users_v01（プライベート）とpublic_profiles（公開）の連携管理
// 設計意図: Domainエンティティ ⟷ Firestore JSON の変換を隠蔽

class UserRepositoryImpl {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // プライベートプロフィール取得
  // 対象: users_v01/{uid} - 本人のみアクセス可能
  Future<MyProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users_v01').doc(uid).get();
      // データが存在しない場合はnullを返す
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      //
      return MyProfile.fromJson(doc.data()!);
    } catch (e) {
      print('ユーザープロフィール取得エラー: $e');
      return null;
    }
  }

  // プライベートプロフィール保存
  // 処理: users_v01への保存 + public_profilesへの同期
  Future<void> saveUserProfile(String uid, MyProfile profile) async {
    final batch = _db.batch();

    try {
      // 1. プライベートデータを保存（users_v01/{uid}）
      final userDoc = _db.collection('users_v01').doc(uid);
      batch.set(userDoc, profile.toJson());

      // 2. 公開データを同期（public_profiles/{userId}）他人の名刺として参照される
      //    - MyProfile → PublicProfile変換でプライベート情報を除外
      final publicProfile = _createPublicProfile(profile, uid);
      final publicDoc = _db.collection('public_profiles').doc(profile.userId);
      batch.set(publicDoc, publicProfile.toJson());

      // 3. userId予約テーブル更新（user_ids/{userId}）
      final userIdDoc = _db.collection('user_ids').doc(profile.userId);
      batch.set(userIdDoc, {
        'ownerUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. 一括実行（全て成功 or 全て失敗）
      await batch.commit();
    } catch (e) {
      print('ユーザープロフィール保存エラー: $e');
      rethrow;
    }
  }

  // 公開プロフィール取得（他者も閲覧可能）
  // 対象: public_profiles/{userId} - 誰でも読み取り可能
  Future<PublicProfile?> getPublicProfile(String userId) async {
    try {
      final doc = await _db.collection('public_profiles').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;

      return PublicProfile.fromJson(doc.data()!);
    } catch (e) {
      print('公開プロフィール取得エラー: $e');
      return null;
    }
  }

  // MyProfile → PublicProfile変換（プライベート情報を除外）
  // 意図: emailなどの機密情報を公開データから排除
  PublicProfile _createPublicProfile(MyProfile profile, String ownerUid) {
    return PublicProfile(
      name: profile.name, // 公開する
      userId: profile.userId, // 公開する（URLに使用）
      avatar: profile.avatar, // 公開する
      message: profile.message, // 公開する
      skills: profile.skills, // 公開する
      github: profile.github, // 公開する
      ownerUid: ownerUid, // セキュリティルール用
      updatedAt: DateTime.now(), // 同期タイムスタンプ
      // 注意: emailは意図的に除外（プライベート情報）
    );
  }
}
