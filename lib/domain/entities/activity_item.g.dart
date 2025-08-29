// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityItemImpl _$$ActivityItemImplFromJson(Map<String, dynamic> json) =>
    _$ActivityItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      kind: $enumDecode(_$ActivityKindEnumMap, json['kind']),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
    );

Map<String, dynamic> _$$ActivityItemImplToJson(_$ActivityItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'kind': _$ActivityKindEnumMap[instance.kind]!,
      'occurredAt': instance.occurredAt.toIso8601String(),
    };

const _$ActivityKindEnumMap = {
  ActivityKind.exchange: 'exchange',
  ActivityKind.update: 'update',
};
