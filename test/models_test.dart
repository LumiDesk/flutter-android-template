import 'package:flutter_test/flutter_test.dart';
import 'package:tpl_starter/app/models/item.dart';
import 'package:tpl_starter/app/models/preferences.dart';

void main() {
  group('Item', () {
    test('JSON 往返保持字段', () {
      final item = Item(
        id: 'a1',
        title: '标题',
        note: '备注',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );

      final restored = Item.fromJson(item.toJson());

      expect(restored.id, item.id);
      expect(restored.title, item.title);
      expect(restored.note, item.note);
      expect(restored.createdAt, item.createdAt);
    });

    test('缺字段时回落到安全默认值', () {
      final restored = Item.fromJson(const <String, Object?>{});

      expect(restored.id, '');
      expect(restored.title, '');
      expect(restored.note, '');
      expect(restored.createdAt.millisecondsSinceEpoch, 0);
    });

    test('copyWith 只改传入的字段', () {
      final item = Item(id: 'a1', title: '旧', createdAt: DateTime(2024));

      final renamed = item.copyWith(title: '新');

      expect(renamed.title, '新');
      expect(renamed.id, 'a1');
      expect(renamed.createdAt, item.createdAt);
    });
  });

  group('TplPreferences', () {
    test('JSON 往返保持字段', () {
      const preferences = TplPreferences(
        themeMode: ThemeModePreference.dark,
        colorMode: ThemeColorMode.system,
        accentIndex: 3,
        languageCode: 'en',
        secureScreen: false,
      );

      final restored = TplPreferences.fromJson(preferences.toJson());

      expect(restored.themeMode, ThemeModePreference.dark);
      expect(restored.colorMode, ThemeColorMode.system);
      expect(restored.accentIndex, 3);
      expect(restored.languageCode, 'en');
      expect(restored.secureScreen, isFalse);
    });

    test('未知枚举值回落到默认值', () {
      final restored = TplPreferences.fromJson(const <String, Object?>{
        'themeMode': 'unknown',
        'colorMode': 'unknown',
      });

      expect(restored.themeMode, ThemeModePreference.system);
      expect(restored.colorMode, ThemeColorMode.preset);
    });
  });
}
