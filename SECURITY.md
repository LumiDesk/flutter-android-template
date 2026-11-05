# Security policy

这个仓库是 Flutter Android 模板，本身不处理用户数据；生成出来的 App 由各自的产品
决定威胁模型。模板层面只保证两件事：

- 发布签名材料不入库，只存在于本机 `signing/` 与仓库 Secrets 里；
- 默认关闭系统自动备份（`allowBackup=false` + `data_extraction_rules.xml`），
  数据只能经应用自己的导出流程离开设备。

## 报告问题

- 模板本身的问题：开 issue，标题以 `template:` 开头。
- 生成后的 App 的安全问题：用该仓库的 **private security advisory**，
  不要开公开 issue；报告里不要带真实数据、口令或密钥。

## 生成新 App 时的检查项

- [ ] `dart run tool/signing.dart` 生成的是这个 App 专属的密钥，不要复用其它 App 的
- [ ] `signing/` 已离线备份；密钥丢失将无法覆盖升级已安装的版本
- [ ] 四个 Secret 只配置在该仓库，不要写进任何文档或日志
- [ ] 新增运行时权限（相机、通知、生物识别）时说明用途，并确认只在需要时申请
- [ ] 接入网络能力时确认 `usesCleartextTraffic` 仍为 `false`
