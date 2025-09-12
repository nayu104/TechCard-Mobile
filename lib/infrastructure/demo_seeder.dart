// lib/infrastructure/demo_seeder.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// デモ名刺投入ユースケース
final demoSeederProvider = Provider<DemoSeeder>((ref) {
  return DemoSeeder(FirebaseFirestore.instance);
});

class DemoSeeder {
  DemoSeeder(this._db);
  final FirebaseFirestore _db;

  /// users/{ownerUid}/contacts にデモ名刺を追加する
  Future<void> seed({required String ownerUid}) async {
    final contactsCol =
        _db.collection('users').doc(ownerUid).collection('contacts');

    // 追加するデモデータ（Contactモデルのスキーマに合わせる）
    final demos = <Map<String, dynamic>>[
      {
        'name': '中山 太郎',
        'userId': 'nakayama',
        'bio': '研究指導・プロジェクト推進',
        'githubUsername': 'nakayama',
        'skills': ['画像情報処理', 'Python', '教育'],
        'company': 'FIT短大／中山研究室',
        'role': '准教授',
        'avatarUrl': null,
      },
      {
        'name': '市來 健一',
        'userId': 'nayu104',
        'bio': '名刺交換アプリ開発中',
        'githubUsername': 'nayu104',
        'skills': ['Flutter', 'React', 'C++', 'データ可視化'],
        'company': 'TechCard Project',
        'role': '学生エンジニア',
        'avatarUrl': null,
      },
      {
        'name': '佐藤 花子',
        'userId': 'hanako_s',
        'bio': 'UI/UX とデザインシステム担当',
        'githubUsername': 'hanako-sample',
        'skills': ['Figma', 'Design System', 'Dart'],
        'company': 'TechCard Project',
        'role': 'Designer',
        'avatarUrl': null,
      },
      {
        'name': '鈴木 次郎',
        'userId': 'jiro_suzuki',
        'bio': 'クラウド基盤とセキュリティ',
        'githubUsername': 'jiro-cloud',
        'skills': ['GCP', 'Firebase', 'SecOps'],
        'company': 'Cloud Ops',
        'role': 'SRE',
        'avatarUrl': null,
      },
      {
        'name': '田中 三郎',
        'userId': 'saburo_t',
        'bio': 'データ可視化が好き',
        'githubUsername': 'saburo-dev',
        'skills': ['Python', 'Pandas', 'Viz'],
        'company': 'Data Works',
        'role': 'Data Engineer',
        'avatarUrl': null,
      },
    ];

    // バッチで投入（createdAt を付与して一覧の orderBy 用にする）
    final batch = _db.batch();
    for (final d in demos) {
      final docRef = contactsCol.doc(); // 自動ID
      batch.set(docRef, {
        ...d,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
