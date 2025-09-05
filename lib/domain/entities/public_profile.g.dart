// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PublicProfileImpl _$$PublicProfileImplFromJson(Map<String, dynamic> json) =>
    _$PublicProfileImpl(
      name: json['name'] as String,
      userId: json['userId'] as String,
      avatar: json['avatar'] as String? ?? '',
      message: json['message'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      github: json['github'] as String?,
      ownerUid: json['ownerUid'] as String,
      updatedAt: const DateTimeTimestampConverter()
          .fromJson(json['updatedAt'] as Timestamp),
    );

Map<String, dynamic> _$$PublicProfileImplToJson(_$PublicProfileImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'userId': instance.userId,
      'avatar': instance.avatar,
      'message': instance.message,
      'skills': instance.skills,
      'github': instance.github,
      'ownerUid': instance.ownerUid,
      'updatedAt':
          const DateTimeTimestampConverter().toJson(instance.updatedAt),
    };
