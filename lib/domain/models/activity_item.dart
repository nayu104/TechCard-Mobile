// 用途: 活動ログ（名刺交換/プロフィール更新）。
// 主フィールド: kindで種別・occurredAtで発生時刻を表す。
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_item.freezed.dart';
part 'activity_item.g.dart';

enum ActivityKind { exchange, update }

@freezed
class ActivityItem with _$ActivityItem {
  const factory ActivityItem({
    required String id,
    required String title,
    required ActivityKind kind,
    required DateTime occurredAt,
  }) = _ActivityItem;

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
}
