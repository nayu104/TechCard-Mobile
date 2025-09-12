import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 検索文字列（URLでも @付きでも可）を保持するプロバイダ
final contactsSearchQueryProvider = StateProvider<String>((ref) => '');

/// 入力文字列から「github のユーザー名」だけを抽出（UIの補助表示用）
/// 例: https://github.com/abc -> abc,  @abc -> abc
String? extractGithubId(String raw) {
  if (raw.trim().isEmpty) return null;

  var t = raw.trim();
  // 先頭の "http(s)://(www.)?github.com/" を取り除く
  t = t.replaceFirst(
    RegExp(r'^(https?:\/\/)?(www\.)?github\.com\/', caseSensitive: false),
    '',
  );
  // 先頭の @ を取り除く
  if (t.startsWith('@')) t = t.substring(1);

  // スラッシュより前だけを見る（/repos などが続いていてもOKに）
  final user = t.split('/').first.trim();

  // GitHubのユーザー名ルール: 英数とハイフン、1〜39文字
  final ok = RegExp(r'^[A-Za-z0-9-]{1,39}$').hasMatch(user);
  return ok ? user : null;
}
