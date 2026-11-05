import 'package:flutter/services.dart';

import '../logging/app_logger.dart';

/// 桌面小组件的 Dart 侧入口。
///
/// 单向数据流：应用把摘要推给 Android，组件只读这份摘要渲染，不反过来回调 Dart。
/// 因此这里不持有状态、不监听、不需要后台 isolate——组件被系统拉起时也不会跑 Flutter。
class HomeWidget {
  HomeWidget._();

  static const MethodChannel _channel = MethodChannel('tpl_starter/native');

  /// 把当前摘要推给所有已添加的小组件。
  ///
  /// 失败只记日志：用户没有添加组件、或运行在测试环境里都不该让主流程报错。
  static Future<void> update({
    required String title,
    required int count,
    required String subtitle,
  }) async {
    try {
      await _channel.invokeMethod<void>('updateHomeWidget', <String, Object?>{
        'title': title,
        'count': count,
        'subtitle': subtitle,
      });
    } on PlatformException catch (error) {
      AppLogger.error('更新桌面小组件失败', error);
    } on MissingPluginException catch (error) {
      AppLogger.error('桌面小组件缺少原生实现', error);
    }
  }
}
