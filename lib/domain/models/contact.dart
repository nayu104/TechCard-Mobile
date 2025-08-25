// 用途: 交換相手の名刺情報。必須=id/name/userId/bio（不変）。
// 一意制約: userIdはアプリ内で一意。整合性はRepositoryで検査。
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
    @Default(<String>[]) List<String> skills, // デフォルト空: UI表示簡素化のため
    String? company,
    String? role,
    String? avatarUrl,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}
