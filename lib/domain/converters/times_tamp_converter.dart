import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

export 'package:cloud_firestore/cloud_firestore.dart';

class DateTimeTimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const DateTimeTimestampConverter();

  // FirestoreのTimestampをDateTimeに変換（デシリアライズ時に使用）
  @override
  DateTime fromJson(Timestamp json) {
    return json.toDate();
  }

  // DateTimeをFirestoreのTimestampに変換（シリアライズ時に使用）
  @override
  Timestamp toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}
