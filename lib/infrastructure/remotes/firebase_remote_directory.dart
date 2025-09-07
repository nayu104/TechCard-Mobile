// DataSource(Remote): Firestoreからユーザー情報を取得。存在しなければnull。
// Mapper方針: Data層のフィールド名に追随し、Domain用に最小変換。
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models.dart';
import '../../domain/repositories.dart';

class FirebaseRemoteDirectory implements RemoteDirectoryRepository {
  FirebaseRemoteDirectory(this.firestore);
  final FirebaseFirestore firestore;

  @override

  /// userIdでFirestoreを検索し、対応するContactを返す。未存在時はnull。
  Future<Contact?> fetchByUserId(String userId) async {
    final snap = await firestore
        .collection('users')
        .where('name', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      return null;
    }
    final doc = snap.docs.first;
    final data = doc.data();
    return Contact(
      id: doc.id,
      name: (data['name'] as String?) ?? userId,
      userId: userId,
      bio: (data['message'] as String?) ?? '',
      githubUsername: (data['github'] as String?)?.toString(),
      skills:
          ((data['skills'] as List?) ?? []).map((e) => e.toString()).toList(),
      avatarUrl: data['avatar'] as String?,
    );
  }

  @override

  /// GitHub名でFirestoreを検索し、対応するContactを返す。未存在時はnull。
  Future<Contact?> fetchByGithubUsername(String githubUsername) async {
    final snap = await firestore
        .collection('users')
        .where('github', isEqualTo: githubUsername)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      return null;
    }
    final doc = snap.docs.first;
    final data = doc.data();
    return Contact(
      id: doc.id,
      name: (data['name'] as String?) ?? githubUsername,
      userId: data['userId'] as String? ?? doc.id,
      bio: (data['message'] as String?) ?? '',
      githubUsername: githubUsername,
      skills:
          ((data['skills'] as List?) ?? []).map((e) => e.toString()).toList(),
      avatarUrl: data['avatar'] as String?,
    );
  }
}
