import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/preferences.dart';

/// 设备偏好存储：一个 JSON 字符串，键固定。
///
/// 只放 UI 偏好；业务数据不要写进这里。
class PreferencesStore {
  static const String storageKey = 'tpl_starter.preferences.v1';

  Future<TplPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const TplPreferences();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return TplPreferences.fromJson(decoded.cast<String, Object?>());
      }
    } on FormatException {
      // 损坏的偏好不应该阻止启动，回落到默认值。
    }
    return const TplPreferences();
  }

  Future<void> save(TplPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(preferences.toJson()));
  }
}
