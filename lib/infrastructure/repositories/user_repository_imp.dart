import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/contact.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../services/location_service.dart';

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
      return MyProfile.fromJson(doc.data()!);
    } on Exception {
      // ユーザープロフィール取得エラー
      return null;
    }
  }

  // 現在の表示用ハンドル（handle）を取得（存在しない場合はnull）
  Future<String?> getCurrentHandle(String userId) async {
    try {
      final doc = await _db.collection('public_profiles').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      final h = data['handle'];
      return h is String && h.isNotEmpty ? h : null;
    } catch (_) {
      return null;
    }
  }

  // 6〜15桁のランダム数値ハンドルを生成
  String _generateNumericHandle() {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    // 乱数ソースとして時刻とランダム値を混ぜる
    final seed =
        now + (DateTime.now().millisecondsSinceEpoch % 1000000).toString();
    // 数字のみを抽出して長さを調整（6〜15桁）
    final digits = seed.replaceAll(RegExp(r'[^0-9]'), '');
    final len = 6 + (digits.hashCode.abs() % 10); // 6..15
    return digits.padRight(len, '0').substring(0, len);
  }

  // 利用可能な数値ハンドルを探して返す（最大5回試行）
  Future<String> _generateAvailableNumericHandle() async {
    for (var i = 0; i < 5; i++) {
      final candidate = _generateNumericHandle();
      final exists = await _db.collection('user_ids').doc(candidate).get();
      if (!exists.exists) return candidate;
    }
    // 最後は Firestore の自動IDを数値化して返す
    final auto =
        _db.collection('user_ids').doc().id.replaceAll(RegExp(r'[^0-9]'), '');
    return (auto.length >= 6 ? auto.substring(0, 15) : auto.padRight(6, '0'));
  }

  // 初期ハンドルの割当（user_ids予約 + public_profiles.handle を設定）
  Future<String> assignInitialHandle(
      {required String uid, required String userId}) async {
    final handle = await _generateAvailableNumericHandle();
    await _db.runTransaction((txn) async {
      final handleRef = _db.collection('user_ids').doc(handle);
      final handleSnap = await txn.get(handleRef);
      if (handleSnap.exists) {
        throw Exception('handle already taken');
      }
      txn.set(handleRef, {
        'ownerUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final pubRef = _db.collection('public_profiles').doc(userId);
      txn.set(
          pubRef,
          {
            'handle': handle,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
    return handle;
  }

  // ハンドル更新（トランザクション）：予約 + 旧ハンドル解放 + public_profiles更新
  Future<void> updateHandleAtomic({
    required String uid,
    required String userId,
    required String? oldHandle,
    required String newHandle,
  }) async {
    // 正規化: 先頭@を除去
    final normalized = newHandle.replaceFirst(RegExp(r'^@'), '');
    // 形式チェック（クライアント側）
    if (!RegExp(r'^[A-Za-z0-9_-]{6,30}$').hasMatch(normalized)) {
      throw ArgumentError('invalid_handle_format');
    }
    await _db.runTransaction((txn) async {
      final newRef = _db.collection('user_ids').doc(normalized);
      final newSnap = await txn.get(newRef);
      if (newSnap.exists) {
        throw Exception('handle_taken');
      }
      // 予約
      txn.set(newRef, {
        'ownerUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 旧ハンドル解放（自分の所有のみ）
      if (oldHandle != null && oldHandle.isNotEmpty) {
        final oldRef = _db.collection('user_ids').doc(oldHandle);
        final oldSnap = await txn.get(oldRef);
        if (oldSnap.exists &&
            (oldSnap.data() as Map<String, dynamic>)['ownerUid'] == uid) {
          txn.delete(oldRef);
        }
      }

      // public_profilesに反映
      final pubRef = _db.collection('public_profiles').doc(userId);
      txn.set(
          pubRef,
          {
            'handle': normalized,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
  }

  // 交換申請（フレンドリクエスト）作成
  Future<void> sendFriendRequest({
    required String senderUid,
    required String senderUserId,
    required String receiverUid,
    required String receiverUserId,
  }) async {
    final now = DateTime.now();
    try {
      // Debug logging removed for production
      await _db.collection('friend_requests').add({
        'senderUid': senderUid,
        'senderUserId': senderUserId,
        'receiverUid': receiverUid,
        'receiverUserId': receiverUserId,
        'status': 'pending',
        'createdAt': now,
        'updatedAt': now,
      });
    } on Exception {
      rethrow;
    }
  }

  // 受信した交換申請の取得（pendingのみ）
  Future<List<Map<String, dynamic>>> getIncomingRequests(String uid) async {
    try {
      // メイン経路: 複合インデックスがある場合
      try {
        final snap = await _db
            .collection('friend_requests')
            .where('receiverUid', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .get();
        return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      } on Exception {
        // フォールバック: インデックス未作成などで失敗した場合は単一条件 + クライアント側フィルタ/ソート
        final snap = await _db
            .collection('friend_requests')
            .where('receiverUid', isEqualTo: uid)
            .get();
        final list = snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .where((m) => (m['status'] as String?) == 'pending')
            .toList();
        list.sort((a, b) {
          final at = a['createdAt'];
          final bt = b['createdAt'];
          // createdAt が null の場合は後ろへ
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return bt.compareTo(at);
        });
        return list;
      }
    } on Exception {
      return [];
    }
  }

  // 申請の状態更新（cancel/decline/accept 等）
  Future<void> updateFriendRequestStatus(
      String requestId, String status) async {
    try {
      await _db.collection('friend_requests').doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception {
      rethrow;
    }
  }

  // 承認時処理: 相互にfriend_idsへ追加 + リクエストをacceptedへ
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final doc = await _db.collection('friend_requests').doc(requestId).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('request not found');
      }
      final data = doc.data()!;
      final senderUid = data['senderUid'] as String;
      final receiverUid = data['receiverUid'] as String;
      final senderUserId = data['senderUserId'] as String;
      final receiverUserId = data['receiverUserId'] as String;

      final batch = _db.batch();
      final reqRef = _db.collection('friend_requests').doc(requestId);
      batch.update(reqRef, {
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 双方向にfriend_ids追加
      final senderRef = _db.collection('users_v01').doc(senderUid);
      final receiverRef = _db.collection('users_v01').doc(receiverUid);
      batch.set(
          senderRef,
          {
            'friend_ids': FieldValue.arrayUnion([receiverUserId]),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
      batch.set(
          receiverRef,
          {
            'friend_ids': FieldValue.arrayUnion([senderUserId]),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      await batch.commit();

      // 位置情報を取得して交換記録を保存
      await _saveExchangeWithLocation(
        senderUid: senderUid,
        receiverUid: receiverUid,
        senderUserId: senderUserId,
        receiverUserId: receiverUserId,
      );

      // Debug logging removed for production
    } on Exception {
      rethrow;
    }
  }

  // 位置情報付きで交換記録を保存
  Future<void> _saveExchangeWithLocation({
    required String senderUid,
    required String receiverUid,
    required String senderUserId,
    required String receiverUserId,
  }) async {
    try {
      // 位置情報を取得
      final position = await LocationService.getCurrentLocation();

      // 相手の名前を取得
      String peerName = '';
      try {
        final peerProfile = await _db
            .collection('public_profiles')
            .where('ownerUid', isEqualTo: senderUid)
            .limit(1)
            .get();
        if (peerProfile.docs.isNotEmpty) {
          peerName = peerProfile.docs.first.data()['name'] as String? ?? '';
        }
      } catch (e) {
        // 名前の取得に失敗しても交換処理は続行
      }

      // 交換記録を作成
      final exchangeData = {
        'ownerUid': receiverUid, // 承認した人が所有者
        'peerUid': senderUid,
        'peerUserId': senderUserId,
        'peerName': peerName,
        'exchangedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 位置情報が取得できた場合は追加
      if (position != null) {
        exchangeData['location'] =
            GeoPoint(position.latitude, position.longitude);
      }

      // 交換記録を保存
      await _db.collection('exchanges').add(exchangeData);
    } catch (e) {
      // 位置情報の取得に失敗しても交換処理は続行
      // Debug logging removed for production
    }
  }

  // フレンド追加（自分のusers_v01にfriend_idsを追記）
  // arrayUnionで重複なく安全に追加する
  Future<void> addFriend(String uid, String friendUserId) async {
    try {
      // Debug logging removed for production
      final docRef = _db.collection('users_v01').doc(uid);
      try {
        // 既存ドキュメント想定の通常パス
        await docRef.update({
          'friend_ids': FieldValue.arrayUnion([friendUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } on Exception {
        // 未作成の場合はmergeで作成しつつ追記
        await docRef.set({
          'friend_ids': FieldValue.arrayUnion([friendUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      // Debug logging removed for production
    } on Exception {
      rethrow;
    }
  }

  // プライベートプロフィール保存
  // 処理: users_v01への保存 + public_profilesへの同期
  Future<void> saveUserProfile(String uid, MyProfile profile) async {
    // Debug logging removed for production
    final batch = _db.batch();

    try {
      // 1. プライベートデータを保存（users_v01/{uid}）
      final userDoc = _db.collection('users_v01').doc(uid);
      batch.set(userDoc, profile.toJson());
      // Debug logging removed for production

      // 2. 公開データを同期（public_profiles/{userId}）他人の名刺として参照される
      //    - MyProfile → PublicProfile変換でプライベート情報を除外
      final publicProfile = _createPublicProfile(profile, uid);
      final publicDoc = _db.collection('public_profiles').doc(profile.userId);
      batch.set(publicDoc, publicProfile.toJson());
      // Debug logging removed for production

      // 3. userId予約テーブル更新（user_ids/{userId}）
      final userIdDoc = _db.collection('user_ids').doc(profile.userId);
      batch.set(userIdDoc, {
        'ownerUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Debug logging removed for production

      // 4. 一括実行（全て成功 or 全て失敗）
      await batch.commit();
      // Debug logging removed for production
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

  /*
  Future<List<Contact>> getContacts(String uid) async {
    try {
      // 1. users_v01/{uid} から friend_ids を直接取得（スキーマに依存しない）
      final userDoc = await _db.collection('users_v01').doc(uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        return [];
      }
      final data = userDoc.data()!;
      final friendIds = ((data['friend_ids'] as List?) ?? [])
          .map((e) => e.toString())
          .toList();
      if (friendIds.isEmpty) {
        return [];
      }

      // 2. friendIdsの公開プロフィールを一括取得
      // 背景: 個別取得（N+1問題）を避けてネットワーク効率を向上
      // 意図: 1回のクエリで全友達のプロフィールを取得
      //初期取得時に利用

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
  */
  // 名刺一覧取得（users/{uid}/contacts から直接読む版）
  Future<List<Contact>> getContacts(String uid) async {
    try {
      final col = _db.collection('users').doc(uid).collection('contacts');
      // createdAt が無ければ orderBy を外してください
      final snap = await col.orderBy('createdAt', descending: true).get();

      return snap.docs.map((d) {
        final data = d.data();
        return Contact.fromJson({
          'id': d.id,
          'name': data['name'] ?? '',
          'userId': data['userId'] ?? '',
          'bio': data['bio'] ?? '',
          'githubUsername': data['githubUsername'],
          'skills': (data['skills'] as List?)?.cast<String>() ?? const [],
          'company': data['company'],
          'role': data['role'],
          'avatarUrl': data['avatarUrl'],
        });
      }).toList();
    } on Exception {
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

  // ゲストUIDから本UIDへのデータ移行
  Future<void> migrateGuestDataToUid({
    required String fromUid,
    required String toUid,
  }) async {
    if (fromUid == toUid) return;
    // 1) users_v01 の統合
    try {
      final fromDoc = await _db.collection('users_v01').doc(fromUid).get();
      if (fromDoc.exists && fromDoc.data() != null) {
        final data = Map<String, dynamic>.from(fromDoc.data()!);
        await _db
            .collection('users_v01')
            .doc(toUid)
            .set(data, SetOptions(merge: true));
      }
    } catch (_) {}

    // 2) public_profiles の ownerUid を toUid に更新（userId は維持）
    try {
      // userId は users_v01 由来のデータを信頼
      final toUser = await _db.collection('users_v01').doc(toUid).get();
      final userId = (toUser.data() ?? const {})['userId']?.toString();
      if (userId != null && userId.isNotEmpty) {
        await _db.collection('public_profiles').doc(userId).set({
          'ownerUid': toUid,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await _db.collection('user_ids').doc(userId).set({
          'ownerUid': toUid,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}

    // 3) exchanges の ownerUid を更新
    try {
      final snaps = await _db
          .collection('exchanges')
          .where('ownerUid', isEqualTo: fromUid)
          .limit(500)
          .get();
      final batch = _db.batch();
      for (final d in snaps.docs) {
        batch.update(d.reference, {
          'ownerUid': toUid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (_) {}
  }

  /// ユーザーIDをアトミックに変更する
  /// 影響範囲:
  /// - user_ids: 新IDを予約、旧IDを解放（本人所有時）
  /// - public_profiles: ドキュメントIDを新IDへ移行（内容は維持し userId を更新）
  /// - users_v01: userId フィールドを更新
  Future<void> updateUserIdAtomic({
    required String uid,
    required String oldUserId,
    required String newUserId,
  }) async {
    final newId = newUserId.replaceFirst(RegExp(r'^@'), '');
    // 形式チェック（英数字/アンダースコア/ハイフン、3〜30）
    if (!RegExp(r'^[A-Za-z0-9_-]{3,30}$').hasMatch(newId)) {
      throw ArgumentError('invalid_user_id_format');
    }

    await _db.runTransaction((txn) async {
      // 参照定義
      final newIdRef = _db.collection('user_ids').doc(newId);
      final oldIdRef = _db.collection('user_ids').doc(oldUserId);
      final oldPubRef = _db.collection('public_profiles').doc(oldUserId);
      final newPubRef = _db.collection('public_profiles').doc(newId);
      final userDoc = _db.collection('users_v01').doc(uid);

      // すべての読み取りを先に行う（トランザクション要件）
      final newIdSnap = await txn.get(newIdRef);
      final oldIdSnap = await txn.get(oldIdRef);
      final oldPubSnap = await txn.get(oldPubRef);

      if (newIdSnap.exists) {
        throw Exception('user_id_taken');
      }

      Map<String, dynamic> oldData = {};
      if (oldPubSnap.exists && oldPubSnap.data() != null) {
        oldData = Map<String, dynamic>.from(oldPubSnap.data()!);
      }

      // 読み取り完了後に書き込みを実行
      txn.set(newIdRef, {
        'ownerUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (oldUserId.isNotEmpty &&
          oldIdSnap.exists &&
          (oldIdSnap.data() as Map<String, dynamic>)['ownerUid'] == uid) {
        txn.delete(oldIdRef);
      }

      txn.set(
          newPubRef,
          {
            ...oldData,
            'userId': newId,
            'ownerUid': uid,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
      if (oldPubSnap.exists) {
        txn.delete(oldPubRef);
      }

      txn.set(
          userDoc,
          {
            'userId': newId,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
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
