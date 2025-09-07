import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/contact.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/entities/user_profile.dart';

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
    } on Exception {
      // ユーザープロフィール取得エラー
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
    } on Exception {
      // ユーザープロフィール保存エラー
      rethrow;
    }
  }

  // 公開プロフィール取得（他者も閲覧可能）
  // 対象: public_profiles/{userId} - 誰でも読み取り可能
  Future<PublicProfile?> getPublicProfile(String userId) async {
    try {
      final doc = await _db.collection('public_profiles').doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return PublicProfile.fromJson(doc.data()!);
    } on Exception {
      // 公開プロフィール取得エラー
      return null;
    }
  }

  // 名刺一覧取得（友達の公開プロフィール一覧）
  // 対象: public_profiles - 友達の公開プロフィールを取得
  // 背景: プルトゥリフレッシュ時に全データを再取得する必要がある
  // 意図: 効率的な一括取得でパフォーマンスを向上させる
  Future<List<Contact>> getContacts(String uid) async {
    try {
      // 1. ユーザーのプロフィールを取得してfriendIdsを取得
      final userProfile = await getUserProfile(uid);
      if (userProfile == null || userProfile.friendIds.isEmpty) {
        return [];
      }

      // 2. friendIdsの公開プロフィールを一括取得
      // 背景: 個別取得（N+1問題）を避けてネットワーク効率を向上
      // 意図: 1回のクエリで全友達のプロフィールを取得
      //初期取得時に利用
      final friendIds = userProfile.friendIds;

      // FirestoreのwhereInクエリで一括取得
      final querySnapshot = await _db
          .collection('public_profiles')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      final contacts = <Contact>[];

      for (final doc in querySnapshot.docs) {
        try {
          final publicProfile = PublicProfile.fromJson(doc.data());
          // PublicProfile → Contact変換
          final contact = Contact(
            id: publicProfile.userId,
            name: publicProfile.name,
            userId: publicProfile.userId,
            bio: publicProfile.message,
            githubUsername: _extractGithubUsername(publicProfile.github),
            skills: publicProfile.skills,
            avatarUrl: publicProfile.avatar,
          );
          contacts.add(contact);
        } on Exception {
          // プロフィール変換エラー
          // エラーが発生したプロフィールはスキップ
        }
      }

      return contacts;
    } on Exception {
      // 名刺一覧取得エラー
      return [];
    }
  }

  // 特定ユーザーのプロフィール差分更新
  // 背景: ユーザーがメッセージを更新した際、そのユーザーのみを更新したい
  // 意図: ピンポイントで特定のプロフィールのみを取得して差分更新
  Future<Contact?> getContactUpdate(String userId) async {
    try {
      final doc = await _db.collection('public_profiles').doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final publicProfile = PublicProfile.fromJson(doc.data()!);
      return Contact(
        id: publicProfile.userId,
        name: publicProfile.name,
        userId: publicProfile.userId,
        bio: publicProfile.message,
        githubUsername: _extractGithubUsername(publicProfile.github),
        skills: publicProfile.skills,
        avatarUrl: publicProfile.avatar,
      );
    } on Exception {
      // プロフィール差分更新エラー
      return null;
    }
  }

  // GitHub URLからユーザー名を抽出
  String _extractGithubUsername(String? githubUrl) {
    if (githubUrl == null || githubUrl.isEmpty) {
      return '';
    }
    final uri = Uri.tryParse(githubUrl);
    if (uri == null) {
      return '';
    }
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.first;
    }
    return '';
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
