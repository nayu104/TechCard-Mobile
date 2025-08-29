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

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get name => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  String? get githubUsername => throw _privateConstructorUsedError;
  List<String> get skills => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String name,
      String userId,
      String bio,
      String? githubUsername,
      List<String> skills,
      String? company,
      String? role,
      String? avatarUrl});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? userId = null,
    Object? bio = null,
    Object? githubUsername = freezed,
    Object? skills = null,
    Object? company = freezed,
    Object? role = freezed,
    Object? avatarUrl = freezed,
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
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      githubUsername: freezed == githubUsername
          ? _value.githubUsername
          : githubUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      skills: null == skills
          ? _value.skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String userId,
      String bio,
      String? githubUsername,
      List<String> skills,
      String? company,
      String? role,
      String? avatarUrl});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? userId = null,
    Object? bio = null,
    Object? githubUsername = freezed,
    Object? skills = null,
    Object? company = freezed,
    Object? role = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$UserProfileImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      githubUsername: freezed == githubUsername
          ? _value.githubUsername
          : githubUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      skills: null == skills
          ? _value._skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.name,
      required this.userId,
      required this.bio,
      this.githubUsername,
      final List<String> skills = const <String>[],
      this.company,
      this.role,
      this.avatarUrl})
      : _skills = skills;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String name;
  @override
  final String userId;
  @override
  final String bio;
  @override
  final String? githubUsername;
  final List<String> _skills;
  @override
  @JsonKey()
  List<String> get skills {
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skills);
  }

  @override
  final String? company;
  @override
  final String? role;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'UserProfile(name: $name, userId: $userId, bio: $bio, githubUsername: $githubUsername, skills: $skills, company: $company, role: $role, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.githubUsername, githubUsername) ||
                other.githubUsername == githubUsername) &&
            const DeepCollectionEquality().equals(other._skills, _skills) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      userId,
      bio,
      githubUsername,
      const DeepCollectionEquality().hash(_skills),
      company,
      role,
      avatarUrl);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String name,
      required final String userId,
      required final String bio,
      final String? githubUsername,
      final List<String> skills,
      final String? company,
      final String? role,
      final String? avatarUrl}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get name;
  @override
  String get userId;
  @override
  String get bio;
  @override
  String? get githubUsername;
  @override
  List<String> get skills;
  @override
  String? get company;
  @override
  String? get role;
  @override
  String? get avatarUrl;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
