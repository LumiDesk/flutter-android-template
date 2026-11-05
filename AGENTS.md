# AGENTS.md

写给在此仓库工作的 AI 代理（DeepSeek Harness）与未来的自己。用户使用中文沟通。

## 1. 这是什么

<!-- BEGIN TEMPLATE INTRO（这段由 tool/init.dart 在初始化时整体替换） -->
- **Flutter + Dart 的 Android 应用骨架**：本地优先、Material 3、中英双语、CI 与签名发版链路齐备。
- 仓库有两个身份：**模板本体**（Dart 包名 `tpl_starter`，类前缀 `Tpl`）和 **`tool/init.dart` 生成后的具体 App**。
  新项目初始化后 `tool/init.dart` 会被删除，其余约定不变。
<!-- END TEMPLATE INTRO -->
- 只用 `android/` 作为交付目标，不维护 Web/桌面/iOS。
- 包管理器：**pub**（`flutter pub get` / `flutter pub add`）；不引入 npm/yarn。
- 工具链：Flutter 3.47.2（与 CI 固定版本一致）、Java 17、Android SDK。

## 2. 目录结构

```text
lib/
├── main.dart                  # 入口：bootstrap、错误上报、根路由
├── app/
│   ├── app_controller.dart    # 权威状态（ChangeNotifier），UI 只调它
│   ├── app_scope.dart         # InheritedNotifier 注入
│   ├── app_state.dart         # TplState + TplError / TplNotice 枚举
│   ├── app_theme.dart         # 设计令牌与 ThemeData
│   ├── app_version.dart       # 展示用版本号，由 scripts/publish.dart 维护
│   ├── feedback.dart          # 轻反馈宿主（唯一入口）
│   ├── messages.dart          # 错误码/提示码 → 文案
│   ├── models/                # item（示例领域）与 preferences
│   ├── data/                  # items_repository、preferences_store
│   ├── logging/               # AppLogger
│   ├── platform/              # NativeBridge（唯一 MethodChannel 入口）
│   └── common_widgets_*.dart  # 通用组件，按 part 拆在 common_widgets.dart 下
├── pages/                      # app_shell / home / settings / sheets
├── l10n/                       # 中英 ARB 与已提交的 gen-l10n 产物
android/                        # 原生桥、Manifest、Gradle 签名读取
scripts/                        # doctor、publish 与共用 cli/environment
tool/                           # init（改名）、signing（密钥）
test/                           # 单元测试与 widget 测试
docs/                           # 当前事实：设计系统、架构、测试、发版
.agents/notes/                  # 设计与决策记录（为什么这么定、否掉了什么）
CLAUDE.md                       # 一行指向 AGENTS.md，别改
```

### 状态与数据流

- 权威状态集中在 `TplController`（`ChangeNotifier`），经 `TplScope`（`InheritedNotifier`）注入；
  不使用 Provider / Riverpod / Bloc。
- 存储只在 `lib/app/data/` 里：`ItemsRepository`（带 `schemaVersion` 的 JSON）、`PreferencesStore`（设备偏好）。
  UI 与 Controller 都不直接读写文件或 `SharedPreferences`。
- 一次性提示与错误用枚举（`TplNotice` / `TplError`）表达，文案在 `messages.dart` 查 ARB；
  由 `main.dart` 的监听统一消费成轻反馈，消费后清空。
- 示例领域（items）是**可删的**：换业务时把 `models/item.dart`、`data/items_repository.dart`
  和 Controller 里的 CRUD 换成你的领域操作，保留「Controller → Repository → 存储」这一层。

## 3. 文档地图

判断“当前实现事实”的顺序：源码/测试/工作流 → `AGENTS.md` → `README.md` → `docs/`。

- `README.md`：项目门面（是什么、功能、技术栈、构建）。
- `docs/design/design-system.md`：颜色、字号、表面材质与验收约定。
- `docs/design/components.md`：组件与弹层 helper 注册表；写新 Widget 前先查。
- `docs/dev/architecture.md`：分层、数据流、如何加一个页面或原生能力。
- `docs/dev/testing.md`：测试分层、覆盖率口径与模拟器验收清单。
- `docs/dev/release.md`：版本号、签名 Secret、发布流程与检查清单。
- `docs/dev/android-development.md`：环境搭建、常用命令、已知故障。
- `docs/release-notes/vX.Y.Z.md`：Release 正文唯一来源。
- `.agents/notes/`：设计稿、技术选型、被否决的方案。**不是当前事实**，只记来龙去脉；
  规则见 `.agents/notes/README.md`。

## 4. 文档同步

文档与注释只描述**当前实现和当前状态**。仓库里不得保留：

- 旧版本、旧实现、旧格式的说明，以及“迁移前/迁移后”的叙事；
- 已删除的功能、旧名称、旧路径、旧依赖的残留引用；
- `docs/` 与 `README.md` 里的方案草稿、实施计划、评审记录、被否决的选项。

具体规则：

- 要写设计稿、备选方案或“为什么不这么做”时，去 `.agents/notes/proposed/`，不要写进 `docs/`。
- 方案落地后：结论合并进 `docs/` 与 `README.md`，笔记移到 `.agents/notes/implemented/`，
  只在笔记里补事实同步（路径、类名、默认值）。
- 行为、依赖、目录、构建或发版流程变化时，在**同一个提交**内更新受影响的 `README.md`、`AGENTS.md`、`docs/` 与代码注释。
- 删除功能时直接从文档、注释和注册表里删掉，不写“已移除/旧版兼容”说明；只有用户可见的变化才进 `CHANGELOG.md`。
- 新增或改名可复用组件、纯函数时同步 `docs/design/components.md`；新增用户可见能力时同步 `README.md`。

## 5. Coding Style

### Dart 与依赖

- 遵循 `dart format` 与 `analysis_options.yaml` 的 flutter_lints + 正确性规则；两个空格缩进。
- 文件名 `snake_case.dart`，类型 `UpperCamelCase`，成员 `lowerCamelCase`，私有加 `_`。
- 不为简单需求新增依赖；新增前评估 APK 体积、隐私与维护成本，并在 `pubspec.yaml` 写一行注释说明用途。
- 不修改生成文件（`lib/l10n/app_localizations*.dart`、`build/`、`.dart_tool/`）。

### 组件与设计令牌

- 写任何 Widget / 弹层前先查 `docs/design/components.md`，命中就复用或参数化扩展。
- 2–8 项静态受控单选统一使用 `TplMenuRow<T>`；禁止再引入分段控件或底部单选弹层。
- 页面骨架固定 `Scaffold > SafeArea > TplPage`，头部用 `TplHeader` / `TplSubHeader`。
- 颜色只用 `tpl*` 令牌与 `Theme.of(context).colorScheme`；语义色经 `tplSemantic(context, tplDanger)` 取用。
- 表面一律不透明实色：禁止背景模糊、渐变、片元滤镜。

### 弹窗与输入

- 页面不得裸写 `showModalBottomSheet`：自定义内容用 `showTplSheet`；确认用 `showTplConfirm`；文本输入用 `showTplTextInput`。
- 取消/未选统一返回 `null`。

### 国际化

- 新增用户可见文案必须同时写 `lib/l10n/app_zh.arb`（模板）与 `app_en.arb`，经 `AppLocalizations.of(context)` 使用。
- 不手改生成的 `app_localizations*.dart`；改完 ARB 跑 `flutter gen-l10n` 并提交产物。
- `contentDescription` / tooltip 同样需要本地化。

### 异步、错误与日志

- `await` 之后再用 `BuildContext` 必须先判断 `mounted` / `context.mounted`。
- Controller 只暴露 `TplError` / `TplNotice` 枚举，文案由 `messages.dart` 翻译；不要把技术异常字符串直接显示给用户。
- 捕获异常后必须 `AppLogger` 记录或明确注释这是可接受降级；禁止空 `catch`。
- 落盘失败必须让用户知道，不能假装成功。

### 数据与存储

- 存储载荷带 `schemaVersion`；结构变更时 +1，并补升级逻辑与往返测试。
- 模型字段变更同步 `toJson` / `fromJson` 与 `test/models_test.dart`。
- 设备偏好永远可以丢弃重建；业务数据不进偏好。

## 6. Build Commands

```bash
flutter pub get
flutter gen-l10n
dart format .
flutter analyze
flutter test
flutter run -d emulator-5554
flutter build apk --debug
flutter build apk --release --target-platform android-arm64
dart run scripts/doctor.dart
dart run tool/signing.dart
```

## 7. CI 与发版

- `.github/workflows/ci.yml`：push / PR 跑格式、l10n 一致性、analyze、测试与覆盖率、debug APK、release APK（用一次性临时密钥验证 R8 链路）。
- `.github/workflows/release.yml`：推送 `vX.Y.Z` 标签时从仓库 Secrets 解码签名材料，构建 arm64 APK，
  以 `docs/release-notes/vX.Y.Z.md` 为正文创建**预发布**；缺发布说明在构建前失败。
- 发布结果是预发布，真机验收后手动提升为 Latest：`gh release edit vX.Y.Z --prerelease=false --latest`。
- 发版必须得到用户明确授权；入口只有 `dart run scripts/publish.dart patch|minor|major`，流程见 `docs/dev/release.md`。
- `.github/workflows/template-smoke.yml` 只在本仓库有意义（生成新项目并验证）；初始化后会随 `tool/init.dart` 一起删除。

## 8. Never 规则

- Never 把密钥、口令、token 或用户明文写进日志、偏好、文件名或临时文件。
- Never 提交 `signing/` 下的真实密钥；它只在本地与 CI Secret 里存在。
- Never 在渲染路径做文件 IO、大计算或全量排序；这些放到 isolate / 缓存 / 构建期。
- Never 在 Flutter 列表中省略稳定 key。
- Never 让 UI 直接读写存储或 MethodChannel；只经 Controller 与 data/、platform/。
- Never 硬编码 `Color(0x...)`、魔法圆角或中文文案到新组件（令牌与 ARB 除外）。
- Never 手改 `pubspec.lock`、生成的 l10n 文件或构建产物。
- Never 未经授权 push、打标签或发版。
- Never 在仓库里写本机绝对路径、用户名、设备序列号或 SDK/JDK 路径（用 `<android-sdk>` 等占位符）。
- Never 往模板里加与业务相关的代码；模板只收横切关注点。

## 9. Commit 规范

- 格式：`type: summary`，类型 `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`。
- 不写 `Generated by` / `Co-authored-by` 等 AI 署名。
- 独立功能完成并通过验证后及时提交；代码与对应文档、注释放在同一个提交。
- 用户可见的功能与修复写入 `CHANGELOG.md` 顶部 `## [Unreleased]`。

## 10. 完成前检查

- 改动是否严格落在请求范围内，工作树是否干净？
- 新文案是否中英文都进了 ARB？改完是否跑了 `flutter gen-l10n`？
- 新 UI 是否只用令牌？新增组件是否登记进 `docs/design/components.md`？
- 错误是否有日志与用户反馈？异步后是否检查了 `mounted`？
- 是否跑了 `dart format`、`flutter analyze`、`flutter test`？UI 改动是否在模拟器上看过？
- 文档与注释是否同步？是否残留旧名称、旧路径或“历史叙述”？
- 若改的是模板本身：`template-smoke.yml` 的等价流程（`init.dart` 生成 + analyze + test + build）是否仍然通过？
