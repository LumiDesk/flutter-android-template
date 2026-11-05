---
name: release
description: Use when the user asks to publish a new version of this Android app (patch, minor, or major) — merges the feature branch into main with a real merge commit, deletes merged branches, prepares docs and release notes, runs scripts/publish.dart, watches CI to green, fixes trivial failures without asking, and reports the pre-release with its assets.
---

# 发版

把"合并 → 清理 → 发版 → 等 CI → 验收 → 汇报"固化成一条可复现的路径。
这是**用户可见的对外动作**：没有明确授权时，只做到"准备完毕"就停。

## 前提

- 用户明确说了要发版，并给了 `patch` / `minor` / `major`。
- 工作区干净，`main` 与 `origin/main` 同步。
- `signing/` 与四个仓库 Secret 已就位（缺失时 `release.yml` 会在解码签名处失败）。

## 1. 合并到 main（非快进）

功能分支必须经 PR 以合并提交落进 `main`，保证历史里有一个可回退的合并点。

```bash
git push -u origin <branch>
gh pr create --fill --base main
gh pr checks --watch
gh pr merge --merge --delete-branch        # 不要 squash、不要 rebase
git checkout main && git pull --ff-only
```

没有远程分支、只在本地作业时：

```bash
git checkout main
git merge --no-ff <branch>
git branch -d <branch>
git push origin main
```

## 2. 清理已合并的分支

```bash
git branch --merged main | grep -v '^\*' | xargs -r git branch -d
git fetch --prune
```

只删**已合并**的分支；`main` 与正在评审的分支不动。

## 3. 发版前把三份材料写齐

脚本会先检查，缺任何一份都会在改版本号之前退出：

| 文件 | 要求 |
|---|---|
| `CHANGELOG.md` | 新增 `## [X.Y.Z] - YYYY-MM-DD`，只写用户可见变化 |
| `docs/release-notes/vX.Y.Z.md` | Release 正文，模板见 `docs/dev/release.md` |
| `docs/`（按需） | 只写**当前状态**；这版删掉的功能、改掉的路径，从文档里直接删除 |

历史决策、被否决的方案写进 `.agents/notes/`，**不要**塞进 `docs/`：

- 这版做了一个当初讨论过的取舍 → `.agents/notes/implemented/YYYY-MM-DD-<主题>.md`
- 这版否掉了某个方案 → `.agents/notes/rejected/`

## 4. 跑发版脚本

```bash
dart run scripts/publish.dart patch        # 或 minor / major
```

脚本会：改 `pubspec.yaml` 与 `lib/app/app_version.dart` → `dart format` →
`flutter analyze` → `flutter test` → 提交 `chore: release vX.Y.Z` → 打 tag →
推送 `main` 与 tag。

## 5. 盯着 CI 到绿

```bash
gh run list --limit 3
gh run watch <run-id> --exit-status
```

`release.yml` 会构建签名 arm64 APK、生成 sha256、创建**预发布**。

### 失败怎么处置

| 情况 | 处置 |
|---|---|
| 格式、lint、拼写、测试期望过期 | 直接修，重跑，不用汇报 |
| 依赖下载 5xx、网络超时、runner 抖动 | 重跑同一 job；连续两次同因失败才升级 |
| 缺 Secret、缺发布说明 | 补齐后重跑 |
| 需要改产品行为、改数据格式、改签名或包名 | **停下来汇报**，等用户决定 |
| 同一个错误修了两次还在 | **停下来汇报**，给日志和已试过的方案 |

"快速修复"的边界：不改公开接口、不改存储格式、不改发版语义，且能在几分钟内验证。

## 6. 验收预发布

```bash
gh release view vX.Y.Z --json isPrerelease,assets
```

确认：`isPrerelease=true`、APK 与 `.sha256` 两个资产都在、正文来自发布说明文件。
**不要**在这一步提升为 Latest——那要等真机验收通过。

## 7. 汇报

给用户的内容，按这个顺序：

1. 版本与 tag（`vX.Y.Z`），分支合并方式（merge commit）。
2. Release 链接、资产名、sha256。
3. CI 结论；修过什么（如果修过）。
4. 真机验收清单的链接（`docs/dev/testing.md`）。
5. 遗留风险 / 需要用户决定的事。
6. 提升为 Latest 的命令：`gh release edit vX.Y.Z --prerelease=false --latest`。

## Never

- Never 未经授权打 tag 或发 release。
- Never `git push --force` 到 `main`；Never 移动、删除、复用已推送的 tag。
- Never squash 或 rebase 合并到 `main`（会丢掉合并点）。
- Never 替换已上传的 APK；验收不通过就用下一个 `patch` 版本重发。
- Never 把发布说明写成内部重构清单；用户看不懂的改动不进 Highlights。
