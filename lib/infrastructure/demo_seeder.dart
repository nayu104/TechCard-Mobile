import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final demoSeederProvider = Provider<DemoSeeder>((ref) {
  return DemoSeeder(FirebaseFirestore.instance);
});

class DemoSeeder {
  DemoSeeder(this._db);
  final FirebaseFirestore _db;

  /// 現在ユーザーの下にデモ名刺を最低5件作る
  Future<void> seed({required String ownerUid}) async {
    final col = _db.collection('users').doc(ownerUid).collection('contacts');

    // 既に十分あるなら何もしない
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();
    final data = [
      {
        'name': '中山 太郎',
        'github': 'nakayama',
        'company': 'FIT短大／中山研究室',
        'title': '准教授',
        'skills': ['画像情報処理', 'Python', '教育'],
        'note': '研究指導・プロジェクト推進',
        'createdAt': now,
      },
      {
        'name': '市來 健一',
        'github': 'nayu104',
        'company': 'TechCard Project',
        'title': '学生エンジニア',
        'skills': ['Flutter', 'React', 'C++', 'データ可視化'],
        'note': '名刺交換アプリ開発',
        'createdAt': now,
      },
      {
        'name': '田中 花子',
        'github': 'error_hanako',
        'company': 'Fukuoka Systems',
        'title': 'フロントエンド',
        'skills': ['TypeScript', 'Next.js', 'UI/UX'],
        'note': 'デザインもいける',
        'createdAt': now,
      },
      {
        'name': '斎藤 蓮',
        'github': 'ren_saito',
        'company': 'DataWorks',
        'title': 'データエンジニア',
        'skills': ['Python', 'Pandas', 'ETL'],
        'note': '可視化好き',
        'createdAt': now,
      },
      {
        'name': 'Lee Min',
        'github': 'lee_min',
        'company': 'CloudNine',
        'title': 'SRE',
        'skills': ['GCP', 'Kubernetes', 'Terraform'],
        'note': '信頼性・運用',
        'createdAt': now,
      },
    ];

    for (final d in data) {
      final doc = col.doc();
      batch.set(doc, d);
    }
    await batch.commit();
  }
}
