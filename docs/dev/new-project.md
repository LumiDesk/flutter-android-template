# 从模板开一个新项目

模板是一次性拷贝：从这里建出的项目不带本仓库的历史，也不会自动收到后续修改。
所以**开工前把标识定死**，之后只改业务。

## 1. 先设计，别先建仓

设计稿写在 `.agents/notes/proposed/YYYY-MM-DD-<主题>.md`：

```text
背景 → 备选方案 → 决定 → 代价/风险 → 怎么验证
```

`docs/` 只写当前事实，不放进草稿与被否决的方案。设计定稿后，把**结论**合并进 `README.md`
与 `docs/`，笔记移到 `.agents/notes/implemented/`。

## 2. 定死这五个参数

| 参数 | 例子 | 说明 |
|---|---|---|
| 显示名 | `VeriFin` | 桌面图标下的名字、窗口标题 |
| 包名 | `verifin` | Dart 包名 + `applicationId` 末段；小写字母开头，只含小写/数字/下划线 |
| org | `top.talyra42` | 反向域名；和包名一起决定 `applicationId` |
| 前缀 | `Vf` | UI 类名，1–4 字符、大写开头；不给就从显示名推导（`VeriFin`→`Vf`） |
| 一句话定位 | 本地优先的记账 App | 写进 README 与 AGENTS.md |

> `applicationId` 就是应用身份：改了它等于换一个 App，已安装的版本无法覆盖升级。
> 功能可以随便改，这两个（包名 / org）在写第一行代码前定死。

## 3. 建仓库

```bash
gh repo create LumiDesk/<新仓库名> --template LumiDesk/flutter-android-template --private --clone
cd <新仓库名>
```

或者网页上点 **Use this template → Create a new repository**。

## 4. 初始化标识

```bash
dart run tool/init.dart \
  --name <包名> \
  --app-name "<显示名>" \
  --org top.talyra42 \
  --prefix <前缀>
```

它会改包名、`applicationId`、Kotlin 包目录、类前缀（`TplPage`→`VfPage`、`TplController`→`VeriFinController`）、
重置版本到 `0.1.0+1`、重写 README/CHANGELOG/SECURITY/AGENTS 开头，删掉 `tool/init.dart`
与模板专属工作流，最后跑一次 `dart format`。

然后确认工程是绿的：

```bash
flutter pub get
flutter analyze
flutter test
dart run scripts/doctor.dart
```

## 5. 签名与 Secret（每个项目独立）

```bash
dart run tool/signing.dart
```

按它打印的命令配置四个 Secret：

```bash
gh secret set KEYSTORE_BASE64 < signing/release.jks.base64
gh secret set KEYSTORE_PASSWORD --body '<口令>'
gh secret set KEY_ALIAS --body 'app'
gh secret set KEY_PASSWORD --body '<口令>'
```

- **立刻把 `signing/` 离线备份**：密钥丢了就再也发不出能覆盖升级的同名 APK。
- 每个 App 用独立密钥，不要跨项目复用。
- 没配 Secret 时 `release.yml` 会在解码签名那一步明确失败，不会产出未签名包。

## 6. 首次提交

```bash
git add -A
git commit -m "chore: 从模板初始化"
git push
```

CI 会跑格式、l10n 一致性、analyze、测试；`main` 上还会构建一次 release APK（验证 R8 链路）。

## 7. 补上这个 App 自己的内容

- [ ] `README.md` 的功能表、技术栈、构建命令
- [ ] `AGENTS.md` 第 1 节的定位（`init` 已写基础信息）
- [ ] `CHANGELOG.md` 的 `## [0.1.0]` 段
- [ ] 应用图标（`android/app/src/main/res/mipmap-*`）与 `values/colors.xml` 的启动底色
- [ ] 删掉示例领域（`lib/app/models/item.dart`、`data/items_repository.dart`）或改写它

## 常见坑

| 现象 | 原因 |
|---|---|
| `flutter build apk --release` 报缺签名 | 没跑 `tool/signing.dart`，Gradle 故意让它失败而不是发未签名包 |
| `tool/init.dart` 报「目标目录非空」 | `--output` 指到了已有目录；加 `--force` 或换目录 |
| CI 里 `dart run tool/init.dart` 找不到包 | 先 `flutter pub get`，否则没有 package config（smoke 工作流已处理） |
| 生成后仍有 `tpl_` 字样 | 只在非文本文件里（图标、jar）或本表未覆盖的新文件，手动确认 |
