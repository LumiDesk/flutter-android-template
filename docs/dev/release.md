# 发版规范

发布是**用户可见的对外动作**：只有用户明确要求时才执行。本文件定义版本号、签名、发布说明与提升流程；
唯一命令入口是 `dart run scripts/publish.dart`。

## 1. 版本号

- 语义：`patch` 修问题与打磨、`minor` 新增功能、`major` 不兼容变更。
- `versionCode` 每次发版 +1，由脚本维护；不得回退，不得复用已发布过的版本号。
- tag 格式固定 `vX.Y.Z`；**不删除、不移动、不重复使用**已推送的 tag。
- 发版命令只有一种写法：

  ```bash
  dart run scripts/publish.dart patch    # 或 minor / major
  ```

- 脚本会依次：改 `pubspec.yaml` 与 `lib/app/app_version.dart` → `dart format` →
  `flutter analyze` → `flutter test` → 提交 `chore: release vX.Y.Z` → 打 tag →
  推送 `main` 与 tag。`--dry-run` 只打印版本并做必填项检查。

## 2. 签名

签名材料不入库，只存在于两处：本机 `signing/` 与 GitHub 仓库 Secrets。

```bash
dart run tool/signing.dart        # 首次：生成 signing/release.jks + 属性文件
```

它会把四条 `gh secret set` 命令打印出来，照抄执行：

| Secret | 内容 |
|---|---|
| `KEYSTORE_BASE64` | `signing/release.jks.base64` 的内容 |
| `KEYSTORE_PASSWORD` | 密钥库口令 |
| `KEY_ALIAS` | key 别名（默认 `app`） |
| `KEY_PASSWORD` | key 口令 |

- `release.yml` 只在打标签时解码这些 Secret；平时 CI 使用一次性临时密钥验证 release 编译链路。
- 缺少 Secret 时工作流在“Decode signing material”一步明确失败，不会产出未签名包。
- 本机 `flutter build apk --release` 需要 `signing/keystore.properties`，缺失时 Gradle 直接报错并提示跑 `tool/signing.dart`。

## 3. 发版前必须齐的两份文件

| 文件 | 内容 | 检查方 |
|---|---|---|
| `CHANGELOG.md` | 新增 `## [X.Y.Z] - YYYY-MM-DD` 段，只写用户可见变化 | `scripts/publish.dart` |
| `docs/release-notes/vX.Y.Z.md` | Release 正文，模板见第 4 节 | `scripts/publish.dart` 与 `release.yml` |

前两份缺任意一份，脚本在改动版本号之前直接退出；`release.yml` 还会在构建前再查一次发布说明，
避免白跑一次签名构建。两份文件与代码改动放在同一个 `docs: prepare vX.Y.Z release` 提交里。

## 4. Release 正文

唯一来源是 `docs/release-notes/vX.Y.Z.md`，由 `release.yml` 用 `--notes-file` 读取。

### 模板

```markdown
## Highlights

- 一条用户能感知的变化；1–6 条，按重要性排序。
- 每条一行，说明「用户看到什么变了」，不写类名、文件名、内部重构。

## Upgrade note

仅当存在不兼容或需要用户先操作的事项时保留：数据格式变化、必须先导出备份、
签名或包名变化。没有就整段删掉。

Install this build over X.Y.Z; local data and preferences are unchanged.

SHA-256 is published next to the APK.
```

### 写作规则

- 只写用户可见的变化；内部重构、测试、依赖升级、文档整理不进发布说明。
- `Highlights` 最多 6 条；超过说明这次发版该拆成 minor 或多写 CHANGELOG 细节。
- 不写 PR 号、commit 号、贡献者名单，不加 emoji。
- 结尾两行固定保留：一句安装/兼容说明，一行 SHA-256 提示。

## 5. 发布流程

1. 写齐第 3 节的两份文件，提交 `docs: prepare vX.Y.Z release` 并推送 `main`。
2. 运行 `dart run scripts/publish.dart patch`；脚本自检、提交、打 tag、推送。
3. `.github/workflows/release.yml` 构建签名 arm64 APK，创建**预发布**。
4. 在真机上按 [testing.md](testing.md) 的主链路验收。
5. 验收通过后提升为 Latest：

   ```bash
   gh release edit vX.Y.Z --prerelease=false --latest
   ```

6. 验收不通过：不发 Latest，修复后用下一个 `patch` 版本重发。**不替换**已上传的 APK，也不重用旧 tag。

## 6. 检查清单

- [ ] 用户明确授权发版
- [ ] 工作区干净，`main` 与 `origin/main` 同步
- [ ] `dart format`、`flutter analyze`、`flutter test` 全绿
- [ ] `CHANGELOG.md`、`docs/release-notes/vX.Y.Z.md` 与 `pubspec.yaml` 版本一致
- [ ] 发布说明是英文、1–6 条 Highlights、无内部细节
- [ ] 真机验收通过后才提升 Latest
