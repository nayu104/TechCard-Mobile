import 'package:freezed_annotation/freezed_annotation.dart';
import '../converters/times_tamp_converter.dart';

part 'public_profile.freezed.dart';
part 'public_profile.g.dart';

// 公開プロフィール：名刺交換・NFCで他者が閲覧するデータ
@freezed
class PublicProfile with _$PublicProfile {
  const factory PublicProfile({
    required String name, // 公開表示名
    required String userId, // 一意ID（ドキュメントIDと同じ値）
    @Default('') String avatar, // 公開アバター
    @Default('') String message, // 公開メッセージ
    @Default(<String>[]) List<String> skills, // 公開スキル
    String? github, // 公開GitHub
    required String ownerUid, // 所有者のFirebase UID（権限制御用）
    @DateTimeTimestampConverter() required DateTime updatedAt, // 更新日時
  }) = _PublicProfile;

  const PublicProfile._();

  factory PublicProfile.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileFromJson(json);
}
