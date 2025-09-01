// 役割: アプリ内で発生した活動（名刺交換/プロフィール更新など）を表すイベントのドメインモデル。
// 用途: 画面の「最近の活動」リスト表示や、行動履歴の分析/同期に利用する。
// 意味:
// - id: 一意な識別子（時刻ベース文字列など）
// - title: UI向けにそのまま表示できる短い説明文
// - kind: 活動の種別（交換 or 更新）
// - occurredAt: 活動が発生した日時
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
