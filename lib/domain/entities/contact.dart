// 用途: 交換相手の名刺情報。
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
