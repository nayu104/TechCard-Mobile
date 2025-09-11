export 'entities/activity_item.dart';
export 'entities/contact.dart';
export 'entities/user_profile.dart';

/// ユーザーIDが英数アンダースコアのみ、かつ空でないかを検証。
bool isValidUserId(String value) {
  // 0幅スペースやBOMなど目に見えない文字を除去したうえで判定
  final normalized = normalizeUserId(value);
  // 一部環境ではハイフンを含むIDを使う可能性があるため許容
  final reg = RegExp(r'^[A-Za-z0-9_-]+$');
  final isValid = normalized.isNotEmpty && reg.hasMatch(normalized);
  // Debug logging removed for production
  return isValid;
}

/// ユーザーIDの正規化
/// - 先頭の@を除去
/// - 前後の空白を除去
/// - 0幅スペースやBOM、改行等の不可視文字を除去
String normalizeUserId(String value) {
  var v = value;
  if (v.startsWith('@')) v = v.substring(1);
  v = v.trim();
  // 目に見えない文字を除去
  const invisible = [
    '\u200B', // ZERO WIDTH SPACE
    '\u200C', // ZERO WIDTH NON-JOINER
    '\u200D', // ZERO WIDTH JOINER
    '\uFEFF', // BOM
  ];
  for (final ch in invisible) {
    v = v.replaceAll(RegExp(ch), '');
  }
  // 改行やタブも除去
  v = v.replaceAll(RegExp(r'[\r\n\t]'), '');
  return v;
}
