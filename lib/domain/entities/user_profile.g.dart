// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      avatar: json['avatar'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String,
      createdAt: const DateTimeTimestampConverter()
          .fromJson(json['createdAt'] as Timestamp),
      email: json['email'] as String,
      friendIds: (json['friendIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      github: json['github'] as String?,
      message: json['message'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'avatar': instance.avatar,
      'name': instance.name,
      'userId': instance.userId,
      'createdAt':
          const DateTimeTimestampConverter().toJson(instance.createdAt),
      'email': instance.email,
      'friendIds': instance.friendIds,
      'github': instance.github,
      'message': instance.message,
      'skills': instance.skills,
    };
