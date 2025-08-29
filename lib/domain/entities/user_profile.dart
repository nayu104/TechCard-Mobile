// 用途: 自分の名刺プロフィール。
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
    @Default(<String>[]) List<String> skills,
    String? company,
    String? role,
    String? avatarUrl,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
