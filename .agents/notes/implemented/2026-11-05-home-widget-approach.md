# 桌面小组件为什么用原生 AppWidgetProvider

- 日期：2026-11-05
- 状态：已落地

## 背景

模板需要一个"开箱即用"的桌面小组件示例。verifin 用的是第三方方案，实际表现不稳定：
系统拉起组件的时机不可控，一旦在里面做重活就会被杀或限频。

## 备选方案

| 方案 | 问题 |
|---|---|
| `home_widget` 等第三方包，把 Flutter 组件渲染成图片 | 需要启动 FlutterEngine 或后台 isolate；首次渲染慢，图片尺寸受组件尺寸影响，调试链路长 |
| 在组件里直接跑 Flutter 业务逻辑 | 组件进程生命周期由系统决定，拿不到应用状态，还得处理多实例同步 |
| **原生 `AppWidgetProvider` + `RemoteViews`，只读一份摘要** | 只能渲染 3 个 TextView；复杂视觉要另想办法 |

## 决定

- 数据流单向：Dart 算好标题/数量/摘要，经同一条 MethodChannel 推给 `MainActivity`，
  再写入组件自己的 `SharedPreferences`，最后刷新所有实例。
- 组件侧不启动引擎、不起后台任务、不做定时轮询（`updatePeriodMillis=0`）。
- 刷新时机由应用决定：数据变化、切换语言、冷启动各推一次。

## 代价

- 布局只能用 RemoteViews 支持的控件，视觉上限低；要做图表/进度环得另找方案。
- 组件内的静态文案是 Android 资源，不跟随 Flutter 的 `languageCode`；多语言要加
  `res/values-<lang>/strings.xml`。

## 验证方式

`flutter build apk --debug` 通过（Kotlin + 资源 + Manifest 合并）、CI 的 release 构建通过；
真机行为按 `docs/dev/testing.md` 的小组件清单验收。
