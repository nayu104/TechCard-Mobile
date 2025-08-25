// 用途: 自分の名刺プロフィール。必須=name/userId/bio（不変）。
// 一意制約: userIdはアプリ内で一意。更新はUseCaseで検証。
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String name,
    required String userId,
    required String bio,
    String? githubUsername,
    @Default(<String>[]) List<String> skills, // デフォルト空: UIの扱いを単純化
    String? company,
    String? role,
    String? avatarUrl,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
