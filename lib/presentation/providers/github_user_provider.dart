import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// GitHubユーザー名から表示名を取得するProvider。
final githubDisplayNameProvider =
    FutureProvider.family<String?, String>((ref, username) async {
  if (username.isEmpty) return null;
  final uri = Uri.parse('https://api.github.com/users/$username');
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    final res = await req.close();
    if (res.statusCode != 200) return null;
    final body = await res.transform(utf8.decoder).join();
    final map = jsonDecode(body) as Map<String, dynamic>;
    final name = map['name'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }
    return null;
  } catch (_) {
    return null;
  } finally {
    client.close();
  }
});
