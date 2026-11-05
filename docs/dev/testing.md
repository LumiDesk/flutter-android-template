# 测试

## 分层

| 层 | 位置 | 跑什么 | 什么时候写 |
|---|---|---|---|
| 单元 | `test/models_test.dart` | JSON 往返、`copyWith`、缺失字段回落 | 模型/序列化变更 |
| 单元 | `test/items_repository_test.dart` | 存取、损坏载荷、未知 `schemaVersion` | 存储格式变更 |
| 单元 | `test/app_controller_test.dart` | CRUD、排序、错误码、偏好持久化 | 业务规则变更 |
| Widget | `test/widget_test.dart` | 空状态、新建、校验、设置页 | 主链路 UI 变更 |
| 集成 | `integration_test/`（按需新建） | 真机/模拟器上的端到端链路 | 涉及原生能力时 |

## 命令

```bash
flutter test                      # 全量
flutter test --coverage           # 带覆盖率，CI 用这个
flutter test test/widget_test.dart -n "空库时"   # 只跑一条
```

测试里用 `SharedPreferences.setMockInitialValues({})` 隔离存储，不要依赖真实设备状态。
Widget 测试固定中文（见 `test/widget_test.dart` 的 `useChineseLocale`），避免结果随宿主语言变化。

## 现有覆盖

- `Item` / `TplPreferences` 的 JSON 往返与默认值回落。
- `ItemsRepository` 的正常存取、损坏 JSON、未知版本。
- `TplController` 的启动、排序、校验、编辑删除、偏好持久化、强调色回退。
- `TplApp` 的空状态展示、新建流程、空标题校验、设置页渲染。

## 覆盖率口径

- CI 只上传 `coverage/lcov.info` 产物，不设硬阈值；模板不追求百分比好看。
- 有意义的覆盖是：序列化往返、状态迁移、错误分支。UI 像素细节不靠测试保证。

## 模拟器验收清单

发版前在模拟器（`emulator-5554`）上手动过一遍：

- [ ] 冷启动：启动页 → 主界面，无白屏闪烁
- [ ] 空状态 → 新建条目 → 列表出现，杀掉进程重开仍在
- [ ] 编辑条目：标题/备注保存后列表与详情一致
- [ ] 删除条目：二次确认可取消，确认后消失
- [ ] 空标题保存：弹层内提示，不关闭
- [ ] 切语言：立即生效，重启后保持
- [ ] 切主题：明/暗/跟随系统，重启后保持
- [ ] 强调色：预设与跟随系统都能生效
- [ ] 防截屏：开关生效后系统截图为黑屏（真机更可靠）
- [ ] 桌面小组件：添加后显示条目数与摘要；增删条目后组件跟着变；点击回到应用；重启手机后仍显示上次数据
- [ ] 返回键：弹层可关闭，主界面退出应用
