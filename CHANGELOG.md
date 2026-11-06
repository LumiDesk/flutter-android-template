# Changelog

模板本身的用户可见变更记录（模板的“用户”就是要开新项目的人）。内部重构、测试与文档整理不写入。

## [Unreleased]

- README 增加实机截图：条目列表（明/暗）、新建条目、设置页、桌面小组件。
- 设置页新增「应用日志」：查看 `AppLogger` 的内存缓冲（最近 200 条），可选中复制。
- PR 上的 CI 不再构建 APK（约 1 分钟出结果）；`main` 合并后仍会签名构建一次 release APK，
  并复用 Gradle 缓存，热缓存下 2–3 分钟。
- 新增 `docs/dev/new-project.md`：从模板开新项目的完整步骤（参数、签名 Secret、首次提交）。
- 新增 PR 模板与 dependabot 配置（分组更新，每周最多一个 PR）。

## [0.1.0] - 2026-11-05

- 首个版本：Flutter Android 骨架、中英双语、设计令牌与通用组件、CI/发版工作流、
  `tool/init.dart` 改名脚本与 `tool/signing.dart` 签名脚本。
- 桌面小组件示例：原生 `AppWidgetProvider` + `RemoteViews`，显示条目数与摘要，点击回到应用。
- `.agents/skills/release`：把「合并 → 清理分支 → 发版 → 等 CI → 验收 → 汇报」固化成一条流程。
- `.agents/notes`：设计稿与决策记录从 `docs/` 分离出来，按 proposed / implemented / rejected 归档。
- 可直接安装的模板 APK：Releases 里提供 arm64 包，用来在手机上查看模板效果。
