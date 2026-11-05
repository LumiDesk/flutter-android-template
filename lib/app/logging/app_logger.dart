import 'package:flutter/foundation.dart';

/// 极简日志：控制台输出 + 内存环形缓冲，供「应用日志」页或导出诊断使用。
///
/// 规则：用户数据、口令、密钥一律不进日志。
class AppLogger {
  AppLogger._();

  static const int _maxEntries = 200;
  static final List<String> _entries = <String>[];

  /// 最近日志，最旧的在前。
  static List<String> get recent => List<String>.unmodifiable(_entries);

  static void info(String message) => _add('I', message);

  static void warn(String message) => _add('W', message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _add('E', error == null ? message : '$message: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static void _add(String level, String message) {
    final line = '[$level] ${DateTime.now().toIso8601String()} $message';
    if (kDebugMode) debugPrint(line);
    _entries.add(line);
    if (_entries.length > _maxEntries) _entries.removeAt(0);
  }
}
