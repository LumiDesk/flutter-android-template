# Android 开发环境

## 需要什么

| 项 | 版本 | 说明 |
|---|---|---|
| Flutter | 3.47.2 | CI 固定这个版本，`scripts/doctor.dart` 会比对 |
| JDK | 17 | Gradle 与 `keytool` 都需要；Android Studio 自带的 JBR 也行 |
| Android SDK | API 36（`compileSdk` 随 Flutter） | `ANDROID_HOME` 或 `android/local.properties` |
| 模拟器 | 任意 AVD，建议 API 34+ | 模板默认用 `emulator-5554` 验收 |

## 常用命令

```bash
flutter pub get
dart run scripts/doctor.dart              # 环境自检（只读）
flutter run -d emulator-5554
flutter build apk --debug
dart run tool/signing.dart                # 首次：生成发布签名
flutter build apk --release --target-platform android-arm64
```

## 签名

- `android/app/build.gradle.kts` 在 `signing/keystore.properties` 缺失时让 release 构建**直接失败**，
  避免悄悄产出未签名的包。
- 属性文件可能有 UTF-8 BOM；Gradle 侧已经按 BOM 安全读取，别用记事本存成 ANSI。
- `signing/` 下只有 `README.md` 与 `keystore.properties.example` 入库，其余都在 `.gitignore` 里。

## 已知故障

### `kotlin.incremental=false` 已开启

Windows 上关闭 Kotlin 增量缓存阶段偶发 `AssertionError: Could not close incremental caches`，
会让插件模块编译失败。本项目 Kotlin 只有一条 MethodChannel，关掉增量换稳定构建（见 `android/gradle.properties`）。

### `keytool` 找不到

`dart run tool/signing.dart` 会依次在 PATH、`JAVA_HOME/bin`、`flutter doctor -v` 报告的 JDK、
Android Studio 的 `jbr/bin` 里找。都找不到说明本机没有 JDK：装 JDK 17，或装 Android Studio。

### 构建时提示 SDK XML version 4

```
Warning: SDK processing. This version only understands SDK XML versions up to 3
```

Android Studio 与命令行工具版本不一致导致，属警告；`flutter build` 仍能成功，不用处理。

### 首次构建很慢

Gradle 需要下载 distribution 与依赖，首次 2–5 分钟属正常；之后走缓存。

### 启动白屏

`android/app/src/main/res/values/colors.xml` 的 `launch_background` 与深色画布同色，
如果换了品牌色要同步改这里与 `values-night/styles.xml`。
