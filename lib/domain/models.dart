export 'entities/activity_item.dart';
export 'entities/contact.dart';
export 'entities/user_profile.dart';

/// ユーザーIDが英数アンダースコアのみ、かつ空でないかを検証。
bool isValidUserId(String value) {
  final reg = RegExp(r'^[A-Za-z0-9_]+$');
  return value.isNotEmpty && reg.hasMatch(value);
}
