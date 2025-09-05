// 日本語名前から英数字のユーザーID候補を生成する関数
// 例: "田中 太郎" → "tanaka_taro", "John@Doe!" → "john_doe"

String slugify(String input) {
  final s = input.toLowerCase().trim();

  final normalized = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-');

  final squashed = normalized.replaceAll(RegExp(r'_+'), '_');

  final trimmed = squashed.replaceAll(RegExp(r'^_|_$'), '');

  return trimmed.isEmpty ? 'user' : trimmed;
}
