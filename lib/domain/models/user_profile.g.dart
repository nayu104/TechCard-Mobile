// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      name: json['name'] as String,
      userId: json['userId'] as String,
      bio: json['bio'] as String,
      githubUsername: json['githubUsername'] as String?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      company: json['company'] as String?,
      role: json['role'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'userId': instance.userId,
      'bio': instance.bio,
      'githubUsername': instance.githubUsername,
      'skills': instance.skills,
      'company': instance.company,
      'role': instance.role,
      'avatarUrl': instance.avatarUrl,
    };
