# CI 构建策略：PR 不打包，main 才打包

- 日期：2026-11-05
- 状态：已落地

## 背景

模板最初每次 push / PR 都构建 debug 与 release 两个 APK，单次 CI 381 秒，其中 324 秒花在 Gradle。
PR 的反馈循环被构建时间拖住，而 PR 阶段真正需要的是"代码对不对"，不是"包能不能装"。

## 备选方案

| 方案 | 结论 |
|---|---|
| 保持每次构建两个 APK | 慢，且 debug 包与 release 包的编译覆盖面高度重叠 |
| 只在 PR 构建 debug，main 构建 release | 仍要为 PR 付一次 Gradle 冷启动 |
| **PR 只做静态检查与测试，main 构建 release** | 采用 |
| 干脆不构建 APK，只靠本地验证 | 放弃：Manifest 合并、Kotlin 编译、R8 裁剪的问题会漏到发版才暴露 |

## 决定

- PR / `pull_request` 事件：格式检查、l10n 一致性、analyze、测试、覆盖率。
- `main` 推送与 `workflow_dispatch`：追加"临时密钥 → 构建 release APK → 校验 → 上传产物"。
- 去掉 debug APK：R8 与资源裁剪只有在 release 上才会走到，debug 包不提供额外信号。
- 三个工作流接 `gradle/actions/setup-gradle`；`android/gradle.properties` 开
  `org.gradle.parallel` 与 `org.gradle.caching`。热缓存下 release 构建 61–72 秒。

## 代价

- PR 上不再编译 Kotlin / Manifest，这类错误要等合并进 `main` 才暴露。PR 数量变多时，
  把 `ci.yml` 里构建步骤的 `if` 去掉即可回到"PR 也打包"。
- 合并依赖大版本升级（例如 Actions）时，风险从 PR 转移到了合并后的 `main`；
  坏了就用 `git revert` 回滚那次合并。

## 验证方式

同一份代码跑两遍对比：冷缓存 238 秒、热缓存 167 秒；PR 路径 59–79 秒。
数据与步骤明细记在当时的提交说明里，结论以 `ci.yml` 的步骤为准。
