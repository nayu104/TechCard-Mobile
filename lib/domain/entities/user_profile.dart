// 役割: 自分の名刺プロフィールを表すドメインモデル。
// 用途: マイカード表示/編集、交換データに埋め込む自分側の情報として利用する。
// スキーマ（Firestore/JSON）:
// - avatar: String（GitHub等のアバターURL）
// - userId: String（@handle）
// - createdAt: Timestamp <-> DateTime（コンバータで相互変換）
// - email: String
// - friend_ids: String[]（Dart側では friendIds にマップ）
// - github: String?（プロフィールURLやユーザー名）
// - message: String（ひとこと、最大50文字想定）
// - skills: String[]
import 'package:freezed_annotation/freezed_annotation.dart';
import '../converters/times_tamp_converter.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class MyProfile with _$MyProfile {
  const factory MyProfile({
    required String avatar,
    required String name,
    required String userId,
    required String email,
    String? github,
    @Default('') String message,
    @Default(<String>[]) List<String> friendIds,
    @Default(<String>[]) List<String> skills,
    @DateTimeTimestampConverter() required DateTime createdAt,
    @DateTimeTimestampConverter() required DateTime updatedAt,
  }) = _MyProfile;

  factory MyProfile.fromJson(Map<String, dynamic> json) =>
      _$MyProfileFromJson(json);
}
