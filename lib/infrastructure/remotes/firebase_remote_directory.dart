// DataSource(Remote): Firestoreからユーザー情報を取得。存在しなければnull。
// Mapper方針: Data層のフィールド名に追随し、Domain用に最小変換。
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models.dart';
import '../../domain/repositories.dart';

class FirebaseRemoteDirectory implements RemoteDirectoryRepository {
  FirebaseRemoteDirectory(this.firestore);
  final FirebaseFirestore firestore;

  @override

  /// 入力ID（@あり/なし対応）でユーザーを検索。
  /// 優先順: user_ids(ハンドル) -> public_profiles(ドキュメントID一致)
  Future<Contact?> fetchByUserId(String input) async {
    final normalized = input.replaceFirst(RegExp(r'^@'), '');
    // Debug logging removed for production

    try {
      // 1) user_ids（ハンドル）で解決
      final handleDoc =
          await firestore.collection('user_ids').doc(normalized).get();
      if (handleDoc.exists && handleDoc.data() != null) {
        final ownerUid = handleDoc.data()!['ownerUid']?.toString();
        if (ownerUid != null && ownerUid.isNotEmpty) {
          final q = await firestore
              .collection('public_profiles')
              .where('ownerUid', isEqualTo: ownerUid)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) {
            final d = q.docs.first;
            final data = d.data();
            return Contact(
              id: data['userId'] as String? ?? d.id,
              name: (data['name'] as String?) ?? normalized,
              userId: data['userId'] as String? ?? d.id,
              bio: (data['message'] as String?) ?? '',
              githubUsername: _extractGithubUsername(data['github'] as String?),
              skills: ((data['skills'] as List?) ?? [])
                  .map((e) => e.toString())
                  .toList(),
              avatarUrl: data['avatar'] as String?,
            );
          }
        }
      }

      // 2) フォールバック: public_profiles のdocId一致
      final doc =
          await firestore.collection('public_profiles').doc(normalized).get();
      if (!doc.exists || doc.data() == null) {
        // Debug logging removed for production
        return null;
      }
      // Debug logging removed for production
      final data = doc.data() as Map<String, dynamic>;
      return Contact(
        id: data['userId'] as String? ?? normalized,
        name: (data['name'] as String?) ?? normalized,
        userId: (data['userId'] as String?) ?? normalized,
        bio: (data['message'] as String?) ?? '',
        githubUsername: _extractGithubUsername(data['github'] as String?),
        skills:
            ((data['skills'] as List?) ?? []).map((e) => e.toString()).toList(),
        avatarUrl: data['avatar'] as String?,
      );
    } catch (e) {
      // Debug logging removed for production
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

  @override

  /// GitHub名でFirestoreを検索し、対応するContactを返す。未存在時はnull。
  Future<Contact?> fetchByGithubUsername(String githubUsername) async {
    // Debug logging removed for production

    try {
      // Firestoreの 'github' フィールドには多くの場合フルURLが格納されるため、
      // よくあるURLパターンも含めて検索する。
      final candidates = <String>{
        githubUsername,
        'https://github.com/$githubUsername',
        'http://github.com/$githubUsername',
        'https://www.github.com/$githubUsername',
        'http://www.github.com/$githubUsername',
      }.toList();

      // Debug logging removed for production

      // whereIn は最大 10 要素まで。今回の候補は5件なので安全。
      final query = firestore
          .collection('public_profiles')
          .where('github', whereIn: candidates)
          .limit(1);

      final snap = await query.get();

      if (snap.docs.isEmpty) {
        // Debug logging removed for production
        return null;
      }

      final doc = snap.docs.first;
      // Debug logging removed for production
      final data = doc.data();

      return Contact(
        id: data['userId'] as String? ?? doc.id,
        name: (data['name'] as String?) ?? githubUsername,
        userId: data['userId'] as String? ?? doc.id,
        bio: (data['message'] as String?) ?? '',
        githubUsername: _extractGithubUsername(data['github'] as String?),
        skills:
            ((data['skills'] as List?) ?? []).map((e) => e.toString()).toList(),
        avatarUrl: data['avatar'] as String?,
      );
    } catch (e) {
      // Debug logging removed for production
      return null;
    }
  }
}
