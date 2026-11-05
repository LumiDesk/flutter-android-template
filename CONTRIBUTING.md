# Contributing

这个仓库主要用于给自己开新项目，所以流程保持轻量。

## 本地检查

提交前跑一遍，和 CI 一致：

```bash
dart format .
flutter analyze
flutter test
```

改了 ARB 要重新生成并提交产物：

```bash
flutter gen-l10n
```

## 改模板本身

模板的每次改动都会被所有未来项目继承，因此：

1. 只加「每个新 App 都要、且与业务无关」的东西；业务相关的一律不进。
2. PR 上 CI 只做静态检查与测试；**合并到 `main` 之后才会真正构建一次 release APK**，
   所以合并后要确认 `main` 的 CI 通过（尤其是动了 Gradle、Manifest 或原生代码时）。
3. 跑一次生成验证（等价于 `template-smoke.yml`）：

   ```bash
   dart run tool/init.dart --name demo_app --app-name "Demo App" \
     --org com.example --prefix Dm --output ../demo_app
   cd ../demo_app && flutter pub get && flutter analyze && flutter test
   ```

3. 改了 `init.dart` 的替换规则时，同步更新 `README.md` 的用法示例与 `AGENTS.md` 的约定。

## 提交信息

`type: summary`，类型 `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`。
不写 AI 署名。
