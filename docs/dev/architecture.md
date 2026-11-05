# 架构

## 分层

```text
pages/            UI：只读状态、只调 Controller
   ↓
app/app_controller.dart   权威状态（ChangeNotifier）：校验、编排、错误码
   ↓
app/data/        存储：ItemsRepository（业务数据）、PreferencesStore（设备偏好）
app/platform/    原生能力：NativeBridge（唯一 MethodChannel 入口）
```

- UI 不直接读写 `SharedPreferences`、文件或 MethodChannel。
- Controller 不碰 `BuildContext`，也不产出用户文案：它只暴露 `TplError` / `TplNotice` 枚举。
- 文案翻译集中在 `app/messages.dart`，由 `main.dart` 的监听消费成轻反馈。

## 数据流

```text
启动：main() → TplController.bootstrap()
        ├─ PreferencesStore.load()  → 主题/语言/强调色
        └─ ItemsRepository.load()   → 列表数据（失败则记录错误码，界面仍可用）

操作：页面 → controller.addItem()/updateItem()/deleteItem()
        ├─ 先改内存 + notifyListeners()（界面立刻响应）
        └─ 再 ItemsRepository.save()（失败 → TplError.storageWrite → 轻反馈）
```

## 状态注入

`TplScope`（`InheritedNotifier<TplController>`）挂在 `MaterialApp.builder` 里，
页面用 `TplScope.of(context)` 取 Controller，Controller 变化时依赖它的页面自动重建。
根级 `AnimatedBuilder` 负责主题与 locale 的变化。

## 加一个页面

1. 在 `lib/pages/` 新建文件，骨架固定 `Scaffold > SafeArea > TplPage`，头部用 `TplHeader`。
2. 需要新状态：在 `TplState` 加字段（不可变 + `copyWith`），在 Controller 加只读 getter 与变更方法。
3. 需要新文案：两份 ARB 同时加 key，跑 `flutter gen-l10n`。
4. 需要新错误/提示：在 `TplError` / `TplNotice` 加枚举值，`messages.dart` 的 switch 会编译失败提醒你补文案。
5. 要挂到底部导航：在 `pages/app_shell.dart` 的 destinations 与 IndexedStack 各加一项。

## 加一条原生能力

1. Android 侧：在 `android/app/src/main/kotlin/<org>/<name>/MainActivity.kt` 的 `MethodChannel` 里加 `call.method` 分支。
2. Dart 侧：在 `lib/app/platform/native_bridge.dart` 加静态方法，捕获 `PlatformException` / `MissingPluginException` 并记日志。
3. 需要权限时同步 `AndroidManifest.xml`，并在 README 的功能表里写清楚用途。
4. 更新本文档的“原生能力”清单与 `docs/design/components.md`（若引入新组件）。

## 存储格式

`ItemsRepository` 的载荷是：

```json
{ "schemaVersion": 1, "items": [ { "id": "...", "title": "...", "note": "...", "createdAt": 1700000000000 } ] }
```

- 结构变更时 `schemaVersion` +1，并在 `load()` 里补旧版本升级；未知版本抛 `ItemsStorageException`，不静默丢数据。
- 设备偏好与业务数据分开存：偏好可以丢弃重建，业务数据不行。
- 数据量变大或需要查询时，把 `ItemsRepository` 换成 sqflite 或应用私有目录文件，接口形状保持不变。
