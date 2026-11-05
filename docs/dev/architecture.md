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

## 原生通道

Dart 侧只有两个入口，都走同一条 channel（`<包名>/native`）：

| Dart 入口 | 方法 | Android 侧 | 说明 |
|---|---|---|---|
| `NativeBridge.setSecureScreen` | `setSecureScreen` | `MainActivity` | 窗口加/清 `FLAG_SECURE` |
| `HomeWidget.update` | `updateHomeWidget` | `MainActivity` → `HomeWidgetProvider` | 写摘要并刷新所有小组件实例 |

约定：channel 名只出现在这两个 Dart 文件与 `MainActivity` 里；页面不直接碰 channel。

## 桌面小组件

刻意**不用**「把 Flutter 渲染成图片塞进 RemoteViews」那类方案，也不在组件里起后台 isolate：

```text
Dart：数据变化 → HomeWidget.update(title, count, subtitle)
                    │ MethodChannel
Android：MainActivity → HomeWidgetProvider.submitAndRefresh
                    │ 写入自身 SharedPreferences
RemoteViews：onUpdate / onEnabled 读摘要 → 渲染 3 个 TextView
```

- 数据单向：组件永远不回读 Flutter 状态，也不启动引擎。
- 刷新时机由应用决定（数据变化、切语言、冷启动）；`updatePeriodMillis=0`，不做系统定时轮询。
- 布局只允许 RemoteViews 支持的控件（`LinearLayout` / `TextView`），见
  `android/app/src/main/res/layout/widget_home.xml`；禁止 Compose、自定义 View、动画、网络图。
- 文案：组件里的静态文字是 Android 资源，不跟随 Flutter 的 `languageCode`；需要多语言就加
  `res/values-en/strings.xml`，别试图复用 ARB。
- 添加/删除组件由系统处理，应用不需要知道实例数量。

## 加一条原生能力

1. Android 侧：在 `android/app/src/main/kotlin/<org>/<name>/MainActivity.kt` 的 `MethodChannel` 里加 `call.method` 分支。
2. Dart 侧：在 `lib/app/platform/` 加静态方法，捕获 `PlatformException` / `MissingPluginException` 并记日志。
3. 需要权限时同步 `AndroidManifest.xml`，并在 README 的功能表里写清楚用途。
4. 同步本文档的“原生通道”表格与 `docs/design/components.md`（若引入新组件）。

## 存储格式

`ItemsRepository` 的载荷是：

```json
{ "schemaVersion": 1, "items": [ { "id": "...", "title": "...", "note": "...", "createdAt": 1700000000000 } ] }
```

- 结构变更时 `schemaVersion` +1，并在 `load()` 里补旧版本升级；未知版本抛 `ItemsStorageException`，不静默丢数据。
- 设备偏好与业务数据分开存：偏好可以丢弃重建，业务数据不行。
- 数据量变大或需要查询时，把 `ItemsRepository` 换成 sqflite 或应用私有目录文件，接口形状保持不变。
