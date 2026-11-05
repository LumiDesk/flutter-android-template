# signing/

发布签名材料。**整个目录都不入 `.gitignore` 之外的版本控制**，只有本文件与
`keystore.properties.example` 可以提交。

## 一次性生成

```bash
dart run tool/signing.dart
```

产物：

| 文件 | 用途 | 是否入库 |
|---|---|---|
| `release.jks` | 签名密钥 | 否 |
| `keystore.properties` | Gradle 读取的属性（含口令） | 否 |
| `release.jks.base64` | 配 GitHub Secret 用 | 否 |

## 配到 GitHub

把 `tool/signing.dart` 输出的四条命令跑一遍（需要 `gh` 已登录、且已 `gh repo set-default`）：

```bash
gh secret set KEYSTORE_BASE64 < signing/release.jks.base64
gh secret set KEYSTORE_PASSWORD --body '<口令>'
gh secret set KEY_ALIAS --body 'app'
gh secret set KEY_PASSWORD --body '<口令>'
```

`release.yml` 只在打 `vX.Y.Z` 标签时解码这些 Secret；`main` 上的 CI 用一次性临时密钥
验证 release 构建链路，不碰你的真实密钥。

## 注意

- 密钥丢了就再也无法用同一个 `applicationId` 覆盖升级已安装的版本，**务必离线备份**。
- 每个 App 用独立密钥，不要跨项目复用。
- 不要把 `.jks`、口令或 base64 贴进 issue、聊天记录或任何提交里。
