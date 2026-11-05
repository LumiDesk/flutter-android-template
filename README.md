<div align="center">

# Flutter Android Template

**可以「Use this template」直接开新 App 的 Flutter Android 骨架。**
本地优先、Material 3、中英双语、CI 与签名发版链路齐备。

![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

</div>

## 这是什么

开新 Android App 时最烦的不是写功能，是把这一堆东西再搭一遍：Gradle 签名配置、
中英文本地化、设计令牌与通用组件、日志与轻反馈、CI 质量门禁、打标签出签名 APK、
版本号脚本、文档骨架、给 AI 代理的工作约定。

这份模板把它们固化下来。从模板建仓库 → 跑一次 `tool/init.dart` → 直接写业务。

## 用法

1. 在 GitHub 上点 **Use this template → Create a new repository**（或本地复制目录）。
2. 在新的仓库根目录初始化标识：

   ```bash
   dart run tool/init.dart \
     --name finance \
     --app-name "VeriFin" \
     --org top.talyra42 \
     --prefix Vf
   ```

   | 参数 | 决定什么 | 例子 |
   |---|---|---|
   | `--name` | Dart 包名、`applicationId` 末段、Kotlin 包目录 | `finance` → `top.talyra42.finance` |
   | `--app-name` | `android:label`、窗口标题、README 标题 | `VeriFin` |
   | `--org` | 反向域名前缀 | `top.talyra42` |
   | `--prefix` | UI 类与令牌前缀（省略则从 app-name 推导） | `Vf` → `VfPage`、`vfRadiusMd` |

   脚本会把 `TplController` 改成 `VeriFinController`、`TplPage` 改成 `VfPage`、
   迁移 Kotlin 包目录、重置版本号为 `0.1.0+1`、重写 README 与 CHANGELOG，
   并删除 `tool/init.dart` 与模板专属的工作流。

3. 拉依赖并确认工程是绿的：

   ```bash
   flutter pub get
   flutter gen-l10n
   dart run scripts/doctor.dart
   flutter test
   ```

4. 生成发布签名，并把四条 Secret 配到 GitHub 仓库：

   ```bash
   dart run tool/signing.dart
   ```

   输出里直接给出 `gh secret set` 命令。没配 Secret 时 `release.yml` 会在解码签名
   那一步明确失败，不会产出未签名包。

5. 提交并推送。CI 会跑格式、analyze、测试、l10n 一致性、debug APK 与 release APK。

## 自带什么

| 层 | 内容 |
|---|---|
| 工程 | Gradle Kotlin DSL、`minSdk 26`、R8 + 资源裁剪、`signing/` 读取签名（缺失即失败）、Gradle wrapper |
| UI | 设计令牌（颜色/圆角/字号）、`TplPage`/`TplCard`/`TplHeader`/`TplEmptyState`/`TplSettingsRow`/`TplMenuRow`/`TplLabeledField` |
| 主题 | 明暗主题、5 套强调色 + 跟随系统动态色、主题模式（系统/浅色/深色）持久化 |
| 状态 | `ChangeNotifier` + `InheritedNotifier`（`TplController` / `TplScope` / `TplState`），错误与提示用枚举码 |
| 本地化 | 中英 ARB（中文为模板源）、`flutter gen-l10n` 产物入库、跟随系统/手动切换 |
| 原生桥 | 一条 `MethodChannel` 示例：`FLAG_SECURE` 防截屏，Dart 侧集中在 `NativeBridge` |
| 存储 | 带 `schemaVersion` 的 JSON 存储示例（`ItemsRepository`）+ 偏好存储；损坏数据有明确异常类型 |
| 反馈 | 统一轻反馈宿主 `TplFeedbackHost`；弹层统一 `showTplSheet`/`showTplConfirm`/`showTplTextInput` |
| 脚本 | `tool/init.dart`（改名）、`tool/signing.dart`（签名）、`scripts/doctor.dart`（环境自检）、`scripts/publish.dart`（发版） |
| CI/CD | `ci.yml`（门禁 + 双 APK）、`release.yml`（tag → 签名 APK + 预发布）、`template-smoke.yml`（模板自检） |
| 文档 | README、AGENTS.md、SECURITY、设计系统、组件注册表、架构、测试、发版规范、发布说明模板 |

## 目录

```text
lib/
├── main.dart                    入口：bootstrap → runApp，错误统一进 AppLogger
├── app/
│   ├── app_controller.dart      权威状态（ChangeNotifier）
│   ├── app_scope.dart           InheritedNotifier 注入
│   ├── app_state.dart           状态 + 错误/提示枚举
│   ├── app_theme.dart           设计令牌与 ThemeData
│   ├── feedback.dart            轻反馈宿主
│   ├── messages.dart            错误码/提示码 → 文案
│   ├── models/                  item（示例领域）与 preferences
│   ├── data/                    items_repository、preferences_store
│   ├── logging/                 AppLogger
│   ├── platform/                NativeBridge（唯一 MethodChannel 入口）
│   └── common_widgets_*.dart    按域拆分的通用组件（part of common_widgets.dart）
├── pages/                       app_shell / home / settings / sheets
└── l10n/                        中英 ARB + 生成物
android/                         原生桥、Manifest、Gradle 签名读取
scripts/                         doctor、publish 与共用 cli/environment
tool/                            init（改名）、signing（密钥）
test/                            单元测试 + widget 测试
docs/                            设计与技术文档
```

## 刻意不带什么

模板越全，新项目要删的东西越多。下面这些按需自己加，别往模板里塞：

- 加密、容器格式、密钥派生（属于具体产品，见各 App 自己的 `SECURITY.md`）
- 数据库（sqflite）、后台同步、推送
- 图标包、图表库、扫码、OCR、生物识别
- 任何与「这个 App 是做什么的」有关的业务模型

判断标准只有一条：**每个新 App 都要、且和业务无关**，才进模板。

## 环境要求

| 项 | 版本 |
|---|---|
| Flutter | 3.47.2（CI 固定；`scripts/doctor.dart` 会比对） |
| Dart | 随 Flutter（3.13.x） |
| JDK | 17 |
| Android SDK | `ANDROID_HOME` 或 `android/local.properties` |
| Git / gh | 发版与配置 Secret 需要 |

详细步骤与常见故障见 [docs/dev/android-development.md](docs/dev/android-development.md)。

## 首次配置清单

- [ ] `dart run tool/init.dart ...` 初始化标识
- [ ] `dart run tool/signing.dart` 生成签名，并按输出配好四个 Secret
- [ ] 在 GitHub 仓库设置里勾上 **Template repository**
- [ ] 把 README 的功能表、`AGENTS.md` 的项目描述改成这个 App 的真实内容
- [ ] 改 Android 启动图标（`android/app/src/main/res/mipmap-*`）与启动底色
- [ ] 第一次发版前写好 `CHANGELOG.md` 与 `docs/release-notes/vX.Y.Z.md`

## 维护这份模板

- 只往模板里加「每个新 App 都要、且与业务无关」的东西。
- 任何改动都必须让 `template-smoke.yml` 保持绿：它会用 `init.dart` 现生成一个项目，
  再对它跑格式、analyze、测试与 debug 构建。
- 改了 `init.dart` 的替换规则、`pubspec` 的包名或前缀，同步改本文档的示例。

## 许可

MIT，见 [LICENSE](LICENSE)。生成出来的 App 用哪种许可由那个项目自己决定。
