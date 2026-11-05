import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpl_starter/app/data/items_repository.dart';
import 'package:tpl_starter/app/models/item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ItemsRepository', () {
    test('空存储读回空列表', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final items = await ItemsRepository().load();

      expect(items, isEmpty);
    });

    test('保存后能原样读回', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = ItemsRepository();
      final items = <Item>[
        Item(id: 'b', title: '第二条', createdAt: DateTime(2024, 2)),
        Item(id: 'a', title: '第一条', note: '备注', createdAt: DateTime(2024, 1)),
      ];

      await repository.save(items);
      final restored = await repository.load();

      expect(restored.map((item) => item.id).toList(), <String>['b', 'a']);
      expect(restored.last.note, '备注');
    });

    test('载荷损坏时抛出 ItemsStorageException', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        ItemsRepository.storageKey: '这不是 JSON',
      });

      expect(
        () => ItemsRepository().load(),
        throwsA(isA<ItemsStorageException>()),
      );
    });

    test('未知的存储版本被拒绝', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        ItemsRepository.storageKey: '{"schemaVersion":99,"items":[]}',
      });

      expect(
        () => ItemsRepository().load(),
        throwsA(isA<ItemsStorageException>()),
      );
    });
  });
}
