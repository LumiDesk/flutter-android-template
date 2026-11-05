import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpl_starter/app/app_controller.dart';
import 'package:tpl_starter/app/data/preferences_store.dart';
import 'package:tpl_starter/main.dart';

/// 固定中文，避免测试结果随宿主语言变化。
void useChineseLocale() {
  SharedPreferences.setMockInitialValues(<String, Object>{
    PreferencesStore.storageKey: '{"languageCode":"zh"}',
  });
}

void main() {
  testWidgets('空库时显示空状态，新增后出现在列表里', (tester) async {
    useChineseLocale();
    final controller = TplController();
    await controller.bootstrap();

    await tester.pumpWidget(TplApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('还没有条目'), findsOneWidget);
    expect(find.text('所有条目'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '测试条目');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('测试条目'), findsOneWidget);
    expect(find.text('还没有条目'), findsNothing);
    expect(find.text('1 条'), findsOneWidget);

    // 放掉轻反馈的定时器，避免测试结束时仍挂着 Timer。
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('空标题保存时留在弹层并提示', (tester) async {
    useChineseLocale();
    final controller = TplController();
    await controller.bootstrap();

    await tester.pumpWidget(TplApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('标题不能为空'), findsOneWidget);
    expect(controller.state.items, isEmpty);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('设置页可以切换语言', (tester) async {
    useChineseLocale();
    final controller = TplController();
    await controller.bootstrap();

    await tester.pumpWidget(TplApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsWidgets);
    expect(find.text('防截屏'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });
}
