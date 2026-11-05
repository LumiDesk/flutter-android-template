import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_state.dart';
import 'data/items_repository.dart';
import 'data/preferences_store.dart';
import 'logging/app_logger.dart';
import 'models/item.dart';
import 'models/preferences.dart';
import 'platform/native_bridge.dart';

/// 权威状态：界面只读它、只调它，不直接碰 repository 或存储。
///
/// 模板用 [ChangeNotifier] + `TplScope` 注入，不引入 Provider / Riverpod / Bloc；
/// 换状态方案时把「UI 只经 Controller」这条边界保留下来即可。
class TplController extends ChangeNotifier {
  TplController({ItemsRepository? items, PreferencesStore? preferences})
    : _items = items ?? ItemsRepository(),
      _preferences = preferences ?? PreferencesStore();

  final ItemsRepository _items;
  final PreferencesStore _preferences;

  TplState _state = const TplState();
  TplPreferences _preferencesValue = const TplPreferences();
  int _sequence = 0;

  TplState get state => _state;
  TplPreferences get preferences => _preferencesValue;

  /// 启动时读偏好与数据；失败不阻塞启动，只把错误交给界面提示。
  Future<void> bootstrap() async {
    _preferencesValue = await _preferences.load();
    try {
      final loaded = await _items.load();
      _state = TplState(
        status: TplStatus.ready,
        items: List<Item>.unmodifiable(loaded),
      );
    } on ItemsStorageException catch (error) {
      AppLogger.error('读取条目失败', error);
      _state = const TplState(
        status: TplStatus.ready,
        error: TplError.storageRead,
      );
    }
    notifyListeners();
  }

  Future<void> addItem({required String title, String note = ''}) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      _setError(TplError.titleRequired);
      return;
    }
    _sequence++;
    final item = Item(
      id: '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-$_sequence',
      title: cleanTitle,
      note: note.trim(),
      createdAt: DateTime.now(),
    );
    await _commit(<Item>[item, ..._state.items], TplNotice.saved);
  }

  Future<void> updateItem(
    String id, {
    required String title,
    String note = '',
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      _setError(TplError.titleRequired);
      return;
    }
    final index = _state.items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final next = List<Item>.of(_state.items);
    next[index] = next[index].copyWith(title: cleanTitle, note: note.trim());
    await _commit(next, TplNotice.saved);
  }

  Future<void> deleteItem(String id) async {
    final next = _state.items
        .where((item) => item.id != id)
        .toList(growable: false);
    if (next.length == _state.items.length) return;
    await _commit(next, TplNotice.deleted);
  }

  /// 偏好类的写入不阻塞界面：先改内存并通知，落盘失败再补一条错误提示。
  void setThemeMode(ThemeModePreference mode) {
    if (_preferencesValue.themeMode == mode) return;
    _preferencesValue = _preferencesValue.copyWith(themeMode: mode);
    notifyListeners();
    unawaited(_persistPreferences());
  }

  void setLanguageCode(String code) {
    if (_preferencesValue.languageCode == code) return;
    _preferencesValue = _preferencesValue.copyWith(languageCode: code);
    notifyListeners();
    unawaited(_persistPreferences());
  }

  /// [presetIndex] 为 null 表示跟随系统动态色。
  void setAccent(int? presetIndex) {
    final mode = presetIndex == null
        ? ThemeColorMode.system
        : ThemeColorMode.preset;
    final index = presetIndex ?? _preferencesValue.accentIndex;
    if (_preferencesValue.colorMode == mode &&
        _preferencesValue.accentIndex == index) {
      return;
    }
    _preferencesValue = _preferencesValue.copyWith(
      colorMode: mode,
      accentIndex: index,
    );
    notifyListeners();
    unawaited(_persistPreferences());
  }

  void setSecureScreen(bool enabled) {
    if (_preferencesValue.secureScreen == enabled) return;
    _preferencesValue = _preferencesValue.copyWith(secureScreen: enabled);
    notifyListeners();
    unawaited(NativeBridge.setSecureScreen(enabled));
    unawaited(_persistPreferences());
  }

  void clearError() {
    if (_state.error == null) return;
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  void clearNotice() {
    if (_state.notice == null) return;
    _state = _state.copyWith(clearNotice: true);
    notifyListeners();
  }

  /// 先改内存再落盘：界面立刻响应，写失败时用错误提示补上真相。
  Future<void> _commit(List<Item> next, TplNotice notice) async {
    _state = _state.copyWith(
      items: List<Item>.unmodifiable(next),
      notice: notice,
      clearError: true,
    );
    notifyListeners();
    try {
      await _items.save(next);
    } on ItemsStorageException catch (error) {
      AppLogger.error('写入条目失败', error);
      _setError(TplError.storageWrite);
    }
  }

  Future<void> _persistPreferences() async {
    try {
      await _preferences.save(_preferencesValue);
    } on Exception catch (error) {
      AppLogger.error('保存偏好失败', error);
      _setError(TplError.storageWrite);
    }
  }

  void _setError(TplError error) {
    _state = _state.copyWith(error: error);
    notifyListeners();
  }
}
