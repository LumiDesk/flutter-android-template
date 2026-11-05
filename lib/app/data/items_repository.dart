import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';

/// 存储层错误：上层据此区分「读不出来」和「写不进去」。
class ItemsStorageException implements Exception {
  ItemsStorageException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'ItemsStorageException: $message${cause == null ? '' : '（$cause）'}';
}

/// 条目存储。
///
/// 模板用共享偏好存一份 JSON 来演示「带版本号的持久化」；真实项目里数据一多
/// 就应该换成 sqflite 或应用私有目录里的文件，只保留这里的接口形状。
class ItemsRepository {
  static const String storageKey = 'tpl_starter.items.v1';

  /// 载荷版本。结构变更时 +1，并在 [load] 里补一段旧版本升级逻辑。
  static const int schemaVersion = 1;

  Future<List<Item>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const <Item>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const FormatException('顶层不是对象');
      }
      final version = (decoded['schemaVersion'] as num?)?.toInt() ?? 0;
      if (version != schemaVersion) {
        throw FormatException('未知的存储版本 $version');
      }
      final list = decoded['items'];
      if (list is! List) {
        throw const FormatException('items 不是数组');
      }
      return list
          .map(
            (entry) => Item.fromJson(
              (entry as Map<Object?, Object?>).cast<String, Object?>(),
            ),
          )
          .toList(growable: false);
    } on FormatException catch (error) {
      throw ItemsStorageException('条目数据无法解析', error);
    } on TypeError catch (error) {
      throw ItemsStorageException('条目字段类型不符', error);
    }
  }

  Future<void> save(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(<String, Object?>{
      'schemaVersion': schemaVersion,
      'items': items.map((item) => item.toJson()).toList(growable: false),
    });
    try {
      final written = await prefs.setString(storageKey, payload);
      if (!written) throw ItemsStorageException('系统拒绝写入');
    } on ItemsStorageException {
      rethrow;
    } on Exception catch (error) {
      throw ItemsStorageException('写入失败', error);
    }
  }
}
