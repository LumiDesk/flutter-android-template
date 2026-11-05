import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpl_starter/app/app_controller.dart';
import 'package:tpl_starter/app/app_state.dart';
import 'package:tpl_starter/app/models/preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('bootstrap 后进入 ready 且没有错误', () async {
    final controller = TplController();

    await controller.bootstrap();

    expect(controller.state.status, TplStatus.ready);
    expect(controller.state.items, isEmpty);
    expect(controller.state.error, isNull);
  });

  test('新增条目按最新在前排序', () async {
    final controller = TplController();
    await controller.bootstrap();

    await controller.addItem(title: '第一条');
    await controller.addItem(title: ' 第二条 ');

    expect(controller.state.items.length, 2);
    expect(controller.state.items.first.title, '第二条');
    expect(controller.state.notice, TplNotice.saved);
  });

  test('空标题被拒绝并给出错误码', () async {
    final controller = TplController();
    await controller.bootstrap();

    await controller.addItem(title: '   ');

    expect(controller.state.items, isEmpty);
    expect(controller.state.error, TplError.titleRequired);
  });

  test('编辑与删除只影响目标条目', () async {
    final controller = TplController();
    await controller.bootstrap();
    await controller.addItem(title: '第一条');
    await controller.addItem(title: '第二条');
    final target = controller.state.items.first;

    await controller.updateItem(target.id, title: '改名', note: '新备注');
    expect(controller.state.items.first.title, '改名');
    expect(controller.state.items.first.note, '新备注');
    expect(controller.state.items.length, 2);

    await controller.deleteItem(target.id);
    expect(controller.state.items.length, 1);
    expect(controller.state.items.single.title, '第一条');
    expect(controller.state.notice, TplNotice.deleted);
  });

  test('偏好写入后重新 bootstrap 仍然保留', () async {
    final first = TplController();
    await first.bootstrap();
    first.setThemeMode(ThemeModePreference.dark);
    first.setLanguageCode('en');
    first.setAccent(2);
    // 让偏好落盘完成。
    await Future<void>.delayed(Duration.zero);

    final second = TplController();
    await second.bootstrap();

    expect(second.preferences.themeMode, ThemeModePreference.dark);
    expect(second.preferences.languageCode, 'en');
    expect(second.preferences.colorMode, ThemeColorMode.preset);
    expect(second.preferences.accentIndex, 2);
  });

  test('setAccent(null) 回到跟随系统', () async {
    final controller = TplController();
    await controller.bootstrap();

    controller.setAccent(4);
    expect(controller.preferences.colorMode, ThemeColorMode.preset);
    expect(controller.preferences.accentIndex, 4);

    controller.setAccent(null);
    expect(controller.preferences.colorMode, ThemeColorMode.system);
  });
}
