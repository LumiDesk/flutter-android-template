import 'package:flutter/widgets.dart';

import 'app_controller.dart';

/// 把 Controller 注入整棵树：controller 变化时依赖它的 widget 自动重建。
class TplScope extends InheritedNotifier<TplController> {
  const TplScope({
    super.key,
    required TplController controller,
    required super.child,
  }) : super(notifier: controller);

  static TplController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'TplScope 未挂载');
    return controller!;
  }

  /// 纯 widget 测试里可以没有 Scope；页面用 of，测试宿主用 maybeOf。
  static TplController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TplScope>()?.notifier;
  }
}
