# 设计系统

界面只有一个来源：`lib/app/app_theme.dart` 里的令牌。页面不硬编码颜色、圆角与字号。

## 颜色

### 画布与表面

| 令牌 | 浅色 | 深色 | 用途 |
|---|---|---|---|
| `tplCanvasLight` / `tplCanvasDark` | `#F3F5F8` | `#101318` | 页面底色（`scaffoldBackgroundColor`） |
| `tplSurfaceLight` / `tplCardSurfaceDark` | `#FFFFFF` | `#1A1F27` | 卡片、输入框 |
| `tplSurfaceRaisedDark` | — | `#232A35` | 弹层、轻反馈、菜单面板 |
| `tplInk` | `#151922` | — | 浅色下的正文色 |
| `tplLine` | `#E1E8F1` | `white10` | 描边与分隔线 |

### 语义色

| 令牌 | 深色下 | 浅色下 | 含义 |
|---|---|---|---|
| `tplAccent` | `#2563EB` | `#2563EB` | 主色（默认强调色） |
| `tplDanger` | `#E84D6A` | `#C2334F` | 删除、错误 |
| `tplWarning` | `#FFB33E` | `#8A5A00` | 需要注意 |
| `tplSuccess` | `#12B8A6` | `#0B7A6C` | 成功、加密完成 |

浅色底语义色统一压暗（`tplSemanticFor`），因为原色在白底对比度不足 AA。
取色一律走 `tplSemantic(context, tplDanger)`，不要直接写 `tplDanger`。

### 强调色

`tplAccentPresets` 是 5 套预设（蓝、青、绿、琥珀、粉），索引与 `TplPreferences.accentIndex` 对应。
`ThemeColorMode.system` 时跟随 Android 12+ 动态色，`preset` 时用预设。

## 圆角与尺寸

| 令牌 | 值 | 用途 |
|---|---|---|
| `tplRadiusSm` | 8 | 小徽章、内联控件 |
| `tplRadiusMd` | 12 | 按钮、输入框、详情行 |
| `tplRadiusLg` | 16 | FAB、菜单项 |
| `tplCardRadius` | 16 | 卡片 |
| `tplRadiusXl` | 24 | 弹层、用户菜单面板 |
| `tplHeaderHeight` | 56 | 页头最小高度 |
| `tplPageMaxWidth` | 440 | 内容最大宽度（大屏居中） |

## 排版

`buildTplTheme` 在 Material 默认字阶上改了一组字号/行高：标题 22/19，正文 14/13，
辅助 12/11，标签 12/11/10。页面只使用 `theme.textTheme.*`，不新建 `TextStyle`。

## 表面规则

- 一律**不透明实色**：禁止背景模糊、渐变、片元滤镜、玻璃拟态。
- 卡片 = 实色 + 16 圆角 + 4.5% 透明度描边。
- 弹层 = `tplElevatedSurfaceColor` + 顶部 24 圆角 + 拖拽把手（由 `showTplSheet` 统一）。

## 验收约定

- 明暗两套都要看：切换 `设置 → 主题`，检查文字对比度与描边。
- 语义色在浅色下不能直接用品红/亮黄的原色（对比度不足）。
- 页面左右安全边距由 `TplPage` 提供，页面内不要再叠 `padding: 16`。
- 列表项必须有稳定 `key`，滚动时不能出现状态错位。
