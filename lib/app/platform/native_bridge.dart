import 'package:flutter/services.dart';

import '../logging/app_logger.dart';

/// 原生能力的唯一入口。
///
/// Dart 侧只在这里碰 MethodChannel；页面和 Controller 都调这些方法，
/// 不直接写 channel 名。新增能力时：Android 侧在 MainActivity 注册，
/// 这里加一个静态方法，并在 docs/dev/architecture.md 补一行。
class NativeBridge {
  NativeBridge._();

  static const MethodChannel _channel = MethodChannel('tpl_starter/native');

  /// 防截屏/录屏：Android 侧为当前窗口加或清 FLAG_SECURE。
  ///
  /// 失败只记日志、不打断用户操作：防截屏是加固项，不是主链路。
  static Future<void> setSecureScreen(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setSecureScreen', <String, Object?>{
        'enabled': enabled,
      });
    } on PlatformException catch (error) {
      AppLogger.error('setSecureScreen 失败', error);
    } on MissingPluginException catch (error) {
      AppLogger.error('setSecureScreen 缺少原生实现', error);
    }
  }
}
