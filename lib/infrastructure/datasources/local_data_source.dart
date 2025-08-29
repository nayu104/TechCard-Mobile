// DataSource: SharedPreferencesベースの簡易永続。キー/スキーマ互換性を維持し、将来の移行で対応。
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalKeys {
  static const profile = 'profile_json'; // スキーマv1: UserProfileのtoJson
  static const contacts = 'contacts_json'; // スキーマv1: Contact[]のtoJson
  static const activities = 'activities_json'; // スキーマv1: ActivityItem[]のtoJson
}

class LocalDataSource {
  LocalDataSource(this.prefs);
  final SharedPreferences prefs;

  /// 文字列で保存されたJSONをMapにデコードして返す。未保存時はnull。
  Map<String, dynamic>? readJson(String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// 文字列で保存されたJSON配列をList<Map>にデコードして返す。未保存時は空配列。
  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  /// MapをJSON文字列化して保存。
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await prefs.setString(key, jsonEncode(value));
  }

  /// List<Map>をJSON文字列化して保存。
  Future<void> writeJsonList(
      String key, List<Map<String, dynamic>> values) async {
    await prefs.setString(key, jsonEncode(values));
  }
}
