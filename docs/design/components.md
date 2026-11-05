# 组件注册表

写新 Widget / 弹层前先查这里：命中就复用或参数化扩展，不要为同一交互另写一套。

## 页面骨架（`lib/app/common_widgets_scaffold.dart`）

| 组件 | 用途 | 关键约定 |
|---|---|---|
| `TplPage` | 页面容器 | 背景色 + 左右 2dp + 最大宽度 440 居中 |
| `TplCard` | 内容卡片 | 实色 + 16 圆角 + 细描边；`onTap` 时自动加 InkWell |
| `TplHeader` | 一级页头 | 标题 + 可选副标题 + 右侧动作，最小高度 56 |
| `TplSubHeader` | 二级页头 | 带返回按钮，`tooltip` 走 ARB |
| `TplSectionLabel` | 卡片外分组标题 | 左侧内缩 16，可带 `trailing` |
| `TplEmptyState` | 空状态 | 圆形图标底 + 标题 + 说明 + 可选主操作 |

## 展示（`lib/app/common_widgets_display.dart`）

| 组件 | 用途 | 关键约定 |
|---|---|---|
| `TplLetterAvatar` | 首字母头像 | 颜色由标题哈希决定，同一标题颜色稳定 |
| `TplInlineError` | 表单内联错误 | 统一图标 + 语义色 + 小字号 |
| `TplKeyValueRow` | 只读键值行 | 左标签右值，设置页/详情页共用 |

## 表单（`lib/app/common_widgets_forms.dart`）

| 组件 | 用途 | 关键约定 |
|---|---|---|
| `TplSettingsRow` | 设置项 | 左图标 + 标题/副标题 + 右侧控件；无 `trailing` 且有 `onTap` 时自动加 chevron |
| `TplSwitchRow` | 开关行 | 点整行即可切换 |
| `TplRowDivider` | 卡片内分隔线 | 默认缩进 58 对齐图标右侧 |
| `TplMenuRow<T>` | 2–8 项静态单选 | 统一走锚点菜单；`dense` 切换紧凑行；`idOf` 不能返回空串 |
| `TplLabeledField` | 带外置标签的输入框 | 多行用 `minLines: 2, maxLines: 4` |

## 弹层（`lib/pages/sheets.dart`）

| 入口 | 用途 | 返回值 |
|---|---|---|
| `showTplSheet<T>` | 自定义底部弹层 | `T?` |
| `showTplConfirm` | 二次确认 | `bool`（取消为 `false`） |
| `showTplTextInput` | 单行/多行文本输入 | `String?`（取消为 `null`） |
| `showTplEditor` | 条目编辑器（`pages/home_page.dart`） | `({String title, String note})?` |

## 反馈

| 组件 | 用途 |
|---|---|
| `TplFeedbackController` | `show(text)` 显示 1.6 秒轻提示 |
| `TplFeedbackHost` | 挂在 `MaterialApp.builder` 上，画在内容上层 |

## 新增组件的流程

1. 先在本表里查同域组件，能参数化就不新增。
2. 归属到现有 part 文件（scaffold / display / forms）；跨域或体量大才新建 part。
3. 只用令牌与 `theme.textTheme`，不写死颜色、圆角、字号。
4. 用户可见文案走 ARB，新增 key 同时补中英两份。
5. 在本表补一行：组件名、用途、关键约定。
