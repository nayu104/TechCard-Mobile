// 役割: 交換相手の名刺情報（連絡先）を表すドメインモデル。
// 用途: 名刺一覧・詳細表示、検索/照合（userId）や活動ログ作成に利用する。
// 意味:
// - id: クライアント側の一意キー
// - name/userId/bio/githubUsername/skills/avatarUrl: 表示用の基本情報
// - company/role: 今後の要件で不要なら削除可能（UI/データ移行を伴うため計画的に）
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact.freezed.dart';
part 'contact.g.dart';

@freezed
class Contact with _$Contact {
  const factory Contact({
    required String id,
    required String name,
    required String userId,
    required String bio,
    String? githubUsername,
    @Default(<String>[]) List<String> skills,
    String? company,
    String? role,
    String? avatarUrl,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}
