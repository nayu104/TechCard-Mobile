// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MyProfile _$MyProfileFromJson(Map<String, dynamic> json) {
  return _MyProfile.fromJson(json);
}

/// @nodoc
mixin _$MyProfile {
  String get avatar => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get github => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<String> get friendIds => throw _privateConstructorUsedError;
  List<String> get skills => throw _privateConstructorUsedError;
  @DateTimeTimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @DateTimeTimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MyProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyProfileCopyWith<MyProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyProfileCopyWith<$Res> {
  factory $MyProfileCopyWith(MyProfile value, $Res Function(MyProfile) then) =
      _$MyProfileCopyWithImpl<$Res, MyProfile>;
  @useResult
  $Res call(
      {String avatar,
      String name,
      String userId,
      String email,
      String? github,
      String message,
      List<String> friendIds,
      List<String> skills,
      @DateTimeTimestampConverter() DateTime createdAt,
      @DateTimeTimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$MyProfileCopyWithImpl<$Res, $Val extends MyProfile>
    implements $MyProfileCopyWith<$Res> {
  _$MyProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avatar = null,
    Object? name = null,
    Object? userId = null,
    Object? email = null,
    Object? github = freezed,
    Object? message = null,
    Object? friendIds = null,
    Object? skills = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      github: freezed == github
          ? _value.github
          : github // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      friendIds: null == friendIds
          ? _value.friendIds
          : friendIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      skills: null == skills
          ? _value.skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MyProfileImplCopyWith<$Res>
    implements $MyProfileCopyWith<$Res> {
  factory _$$MyProfileImplCopyWith(
          _$MyProfileImpl value, $Res Function(_$MyProfileImpl) then) =
      __$$MyProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String avatar,
      String name,
      String userId,
      String email,
      String? github,
      String message,
      List<String> friendIds,
      List<String> skills,
      @DateTimeTimestampConverter() DateTime createdAt,
      @DateTimeTimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$MyProfileImplCopyWithImpl<$Res>
    extends _$MyProfileCopyWithImpl<$Res, _$MyProfileImpl>
    implements _$$MyProfileImplCopyWith<$Res> {
  __$$MyProfileImplCopyWithImpl(
      _$MyProfileImpl _value, $Res Function(_$MyProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of MyProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avatar = null,
    Object? name = null,
    Object? userId = null,
    Object? email = null,
    Object? github = freezed,
    Object? message = null,
    Object? friendIds = null,
    Object? skills = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MyProfileImpl(
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      github: freezed == github
          ? _value.github
          : github // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      friendIds: null == friendIds
          ? _value._friendIds
          : friendIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      skills: null == skills
          ? _value._skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MyProfileImpl implements _MyProfile {
  const _$MyProfileImpl(
      {required this.avatar,
      required this.name,
      required this.userId,
      required this.email,
      this.github,
      this.message = '',
      final List<String> friendIds = const <String>[],
      final List<String> skills = const <String>[],
      @DateTimeTimestampConverter() required this.createdAt,
      @DateTimeTimestampConverter() required this.updatedAt})
      : _friendIds = friendIds,
        _skills = skills;

  factory _$MyProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyProfileImplFromJson(json);

  @override
  final String avatar;
  @override
  final String name;
  @override
  final String userId;
  @override
  final String email;
  @override
  final String? github;
  @override
  @JsonKey()
  final String message;
  final List<String> _friendIds;
  @override
  @JsonKey()
  List<String> get friendIds {
    if (_friendIds is EqualUnmodifiableListView) return _friendIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friendIds);
  }

  final List<String> _skills;
  @override
  @JsonKey()
  List<String> get skills {
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skills);
  }

  @override
  @DateTimeTimestampConverter()
  final DateTime createdAt;
  @override
  @DateTimeTimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'MyProfile(avatar: $avatar, name: $name, userId: $userId, email: $email, github: $github, message: $message, friendIds: $friendIds, skills: $skills, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyProfileImpl &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.github, github) || other.github == github) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._friendIds, _friendIds) &&
            const DeepCollectionEquality().equals(other._skills, _skills) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      avatar,
      name,
      userId,
      email,
      github,
      message,
      const DeepCollectionEquality().hash(_friendIds),
      const DeepCollectionEquality().hash(_skills),
      createdAt,
      updatedAt);

  /// Create a copy of MyProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyProfileImplCopyWith<_$MyProfileImpl> get copyWith =>
      __$$MyProfileImplCopyWithImpl<_$MyProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MyProfileImplToJson(
      this,
    );
  }
}

abstract class _MyProfile implements MyProfile {
  const factory _MyProfile(
          {required final String avatar,
          required final String name,
          required final String userId,
          required final String email,
          final String? github,
          final String message,
          final List<String> friendIds,
          final List<String> skills,
          @DateTimeTimestampConverter() required final DateTime createdAt,
          @DateTimeTimestampConverter() required final DateTime updatedAt}) =
      _$MyProfileImpl;

  factory _MyProfile.fromJson(Map<String, dynamic> json) =
      _$MyProfileImpl.fromJson;

  @override
  String get avatar;
  @override
  String get name;
  @override
  String get userId;
  @override
  String get email;
  @override
  String? get github;
  @override
  String get message;
  @override
  List<String> get friendIds;
  @override
  List<String> get skills;
  @override
  @DateTimeTimestampConverter()
  DateTime get createdAt;
  @override
  @DateTimeTimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of MyProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyProfileImplCopyWith<_$MyProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
