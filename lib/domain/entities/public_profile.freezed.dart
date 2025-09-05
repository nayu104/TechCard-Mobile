// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PublicProfile _$PublicProfileFromJson(Map<String, dynamic> json) {
  return _PublicProfile.fromJson(json);
}

/// @nodoc
mixin _$PublicProfile {
  String get name => throw _privateConstructorUsedError; // 公開表示名
  String get userId => throw _privateConstructorUsedError; // 一意ID（ドキュメントIDと同じ値）
  String get avatar => throw _privateConstructorUsedError; // 公開アバター
  String get message => throw _privateConstructorUsedError; // 公開メッセージ
  List<String> get skills => throw _privateConstructorUsedError; // 公開スキル
  String? get github => throw _privateConstructorUsedError; // 公開GitHub
  String get ownerUid =>
      throw _privateConstructorUsedError; // 所有者のFirebase UID（権限制御用）
  @DateTimeTimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PublicProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicProfileCopyWith<PublicProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicProfileCopyWith<$Res> {
  factory $PublicProfileCopyWith(
          PublicProfile value, $Res Function(PublicProfile) then) =
      _$PublicProfileCopyWithImpl<$Res, PublicProfile>;
  @useResult
  $Res call(
      {String name,
      String userId,
      String avatar,
      String message,
      List<String> skills,
      String? github,
      String ownerUid,
      @DateTimeTimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$PublicProfileCopyWithImpl<$Res, $Val extends PublicProfile>
    implements $PublicProfileCopyWith<$Res> {
  _$PublicProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? userId = null,
    Object? avatar = null,
    Object? message = null,
    Object? skills = null,
    Object? github = freezed,
    Object? ownerUid = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      skills: null == skills
          ? _value.skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      github: freezed == github
          ? _value.github
          : github // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerUid: null == ownerUid
          ? _value.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublicProfileImplCopyWith<$Res>
    implements $PublicProfileCopyWith<$Res> {
  factory _$$PublicProfileImplCopyWith(
          _$PublicProfileImpl value, $Res Function(_$PublicProfileImpl) then) =
      __$$PublicProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String userId,
      String avatar,
      String message,
      List<String> skills,
      String? github,
      String ownerUid,
      @DateTimeTimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$PublicProfileImplCopyWithImpl<$Res>
    extends _$PublicProfileCopyWithImpl<$Res, _$PublicProfileImpl>
    implements _$$PublicProfileImplCopyWith<$Res> {
  __$$PublicProfileImplCopyWithImpl(
      _$PublicProfileImpl _value, $Res Function(_$PublicProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? userId = null,
    Object? avatar = null,
    Object? message = null,
    Object? skills = null,
    Object? github = freezed,
    Object? ownerUid = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PublicProfileImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      skills: null == skills
          ? _value._skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      github: freezed == github
          ? _value.github
          : github // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerUid: null == ownerUid
          ? _value.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicProfileImpl extends _PublicProfile {
  const _$PublicProfileImpl(
      {required this.name,
      required this.userId,
      this.avatar = '',
      this.message = '',
      final List<String> skills = const <String>[],
      this.github,
      required this.ownerUid,
      @DateTimeTimestampConverter() required this.updatedAt})
      : _skills = skills,
        super._();

  factory _$PublicProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicProfileImplFromJson(json);

  @override
  final String name;
// 公開表示名
  @override
  final String userId;
// 一意ID（ドキュメントIDと同じ値）
  @override
  @JsonKey()
  final String avatar;
// 公開アバター
  @override
  @JsonKey()
  final String message;
// 公開メッセージ
  final List<String> _skills;
// 公開メッセージ
  @override
  @JsonKey()
  List<String> get skills {
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skills);
  }

// 公開スキル
  @override
  final String? github;
// 公開GitHub
  @override
  final String ownerUid;
// 所有者のFirebase UID（権限制御用）
  @override
  @DateTimeTimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PublicProfile(name: $name, userId: $userId, avatar: $avatar, message: $message, skills: $skills, github: $github, ownerUid: $ownerUid, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicProfileImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._skills, _skills) &&
            (identical(other.github, github) || other.github == github) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      userId,
      avatar,
      message,
      const DeepCollectionEquality().hash(_skills),
      github,
      ownerUid,
      updatedAt);

  /// Create a copy of PublicProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicProfileImplCopyWith<_$PublicProfileImpl> get copyWith =>
      __$$PublicProfileImplCopyWithImpl<_$PublicProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicProfileImplToJson(
      this,
    );
  }
}

abstract class _PublicProfile extends PublicProfile {
  const factory _PublicProfile(
          {required final String name,
          required final String userId,
          final String avatar,
          final String message,
          final List<String> skills,
          final String? github,
          required final String ownerUid,
          @DateTimeTimestampConverter() required final DateTime updatedAt}) =
      _$PublicProfileImpl;
  const _PublicProfile._() : super._();

  factory _PublicProfile.fromJson(Map<String, dynamic> json) =
      _$PublicProfileImpl.fromJson;

  @override
  String get name; // 公開表示名
  @override
  String get userId; // 一意ID（ドキュメントIDと同じ値）
  @override
  String get avatar; // 公開アバター
  @override
  String get message; // 公開メッセージ
  @override
  List<String> get skills; // 公開スキル
  @override
  String? get github; // 公開GitHub
  @override
  String get ownerUid; // 所有者のFirebase UID（権限制御用）
  @override
  @DateTimeTimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of PublicProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicProfileImplCopyWith<_$PublicProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
