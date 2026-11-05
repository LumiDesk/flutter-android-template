// 模板初始化：把这份模板改成一个具体应用。
//
//   dart run tool/init.dart --name finance --app-name "VeriFin" --org top.talyra42 [--prefix Vf]
//
// 不传 --output 时原地改名（对应 GitHub 上「Use this template」之后的新仓库）；
// 传 --output <目录> 时先复制到该目录再改名（本地生成新项目时用）。
//
// 脚本只依赖 dart:io，可以直接 `dart tool/init.dart` 运行，不需要先 pub get。
// ignore_for_file: avoid_print
import 'dart:io';

/// 模板自身的标识。改模板的包名或显示名时，同步改这里。
const String _templateOrg = 'top.talyra42';
const String _templateDisplayName = 'Tpl Starter';
const String _templatePrefix = 'Tpl';
const String _templateVersion = '0.1.0';

/// 需要做文本替换的扩展名；这些之外一律按二进制跳过。
const Set<String> _textExtensions = <String>{
  '.dart',
  '.yaml',
  '.yml',
  '.kts',
  '.gradle',
  '.kt',
  '.xml',
  '.md',
  '.json',
  '.arb',
  '.properties',
  '.txt',
  '.bat',
  '.sh',
  '.html',
};

const Set<String> _textFileNames = <String>{
  '.gitignore',
  '.gitattributes',
  '.editorconfig',
};

/// 不参与复制与替换的路径（相对仓库根）。
const List<String> _excludedPaths = <String>[
  '.git',
  'build',
  '.dart_tool',
  '.idea',
  'coverage',
  'dist',
  'tmp',
  'android/.gradle',
  'android/.kotlin',
  'android/local.properties',
  'pubspec.lock',
  '.flutter-plugins',
  '.flutter-plugins-dependencies',
  'signing/keystore.properties',
];

/// 初始化后要删掉的模板专属文件（相对仓库根）。
const List<String> _templateOnlyFiles = <String>[
  '.github/workflows/template-smoke.yml',
  'docs/release-notes/v0.1.0.md',
  'tool/init.dart',
];

Future<void> main(List<String> args) async {
  final options = <String, String>{};
  final flags = <String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--')) _fail('未知参数：$arg');
    final key = arg.substring(2);
    if (key == 'help' || key == 'force') {
      flags.add(key);
      continue;
    }
    if (i + 1 >= args.length) _fail('$arg 缺少值');
    options[key] = args[++i];
  }

  if (flags.contains('help')) {
    _printUsage();
    return;
  }

  final source = Directory.current.absolute;
  final packageName = _requireOption(options, 'name');
  final appName = _requireOption(options, 'app-name');
  final org = _requireOption(options, 'org');
  _validatePackageName(packageName);
  _validateOrg(org);
  final appPascal = _pascalOf(appName);
  final prefix = options['prefix']?.trim() ?? _derivePrefix(appName);
  _validatePrefix(prefix);

  final outputOption = options['output'];
  final target = outputOption == null
      ? source
      : Directory(File(outputOption).absolute.path);

  final oldPackageName = _readPackageName(source);

  print('模板：${source.path}');
  print('目标：${target.path}');
  print(
    '标识：name=$packageName  app-name=$appName  org=$org  prefix=$prefix'
    '  ->  ${appPascal}Controller / ${prefix}Page',
  );

  if (target.path != source.path) {
    if (target.existsSync() && target.listSync().isNotEmpty) {
      if (!flags.contains('force')) {
        _fail('目标目录非空：${target.path}；加 --force 覆盖其中的文件');
      }
    }
    _copyTree(source, target);
  }

  final replacements = <({String from, String to})>[
    (from: oldPackageName, to: packageName),
    (from: _templateOrg, to: org),
    (from: _templateDisplayName, to: appName),
    (from: 'TplController', to: '${appPascal}Controller'),
    (from: 'TplScope', to: '${appPascal}Scope'),
    (from: 'TplState', to: '${appPascal}State'),
    (from: 'TplError', to: '${appPascal}Error'),
    (from: 'TplNotice', to: '${appPascal}Notice'),
    (from: 'buildTplTheme', to: 'build${appPascal}Theme'),
  ];

  var rewritten = 0;
  for (final file in _walk(target)) {
    if (!_isTextFile(file)) continue;
    final original = _readText(file);
    if (original == null) continue;

    var updated = original;
    for (final replacement in replacements) {
      if (replacement.from.isEmpty) continue;
      updated = updated.replaceAll(replacement.from, replacement.to);
    }
    // 前缀替换放在最后：先处理更长的专有名称（Controller/Scope/...），
    // 剩下的 Tpl / tpl 才按前缀统一替换。模板里没有含 tpl 的英文单词，可整词替换。
    updated = updated.replaceAll(_templatePrefix, prefix);
    updated = updated.replaceAll(
      _templatePrefix.toLowerCase(),
      prefix.toLowerCase(),
    );

    if (updated != original) {
      file.writeAsStringSync(updated);
      rewritten++;
    }
  }
  print('已改写 $rewritten 个文本文件');

  _renameKotlinPackage(target, oldPackageName, packageName, org);
  _resetVersion(target);
  _writeChangelog(target, appName);
  _writeReadme(target, appName, prefix);
  _writeSecurity(target, appName);
  _rewriteAgentsIntro(target, appName, packageName, org, prefix);
  _deleteTemplateOnlyFiles(target);
  _formatTree(target);

  print('');
  print('完成。下一步：');
  print('  1. flutter pub get');
  print('  2. flutter gen-l10n');
  print('  3. dart run tool/signing.dart      # 生成发布签名，并打印 Secret 配置命令');
  print('  4. dart run scripts/doctor.dart   # 环境自检');
  print('  5. 补 README / AGENTS.md 里这个 App 的真实描述，再提交');
}

void _printUsage() {
  print('''
用法：
  dart run tool/init.dart --name <包名> --app-name "<显示名>" --org <反向域名> \\
      [--prefix <前缀>] [--output <目录>] [--force]

示例：
  dart run tool/init.dart --name finance --app-name "VeriFin" --org top.talyra42 --prefix Vf

参数：
  --name       Dart 包名 / applicationId 末段；小写字母开头，只含小写字母、数字、下划线
  --app-name   应用显示名（android:label、窗口标题）
  --org        反向域名，如 top.talyra42、com.example
  --prefix     UI 类前缀；默认从 app-name 推导（KeyCase -> Kc）
  --output     复制到指定目录后再改名；省略则原地修改
  --force      --output 目标目录非空时覆盖
''');
}

String _requireOption(Map<String, String> options, String key) {
  final value = options[key];
  if (value == null || value.trim().isEmpty) {
    _fail('缺少 --$key；运行 dart run tool/init.dart --help 看用法');
  }
  return value.trim();
}

Never _fail(String message) {
  stderr.writeln('✗ $message');
  exit(64);
}

void _validatePackageName(String value) {
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
    _fail('--name 必须以小写字母开头，且只含小写字母、数字、下划线：$value');
  }
}

void _validateOrg(String value) {
  if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(value)) {
    _fail('--org 必须是反向域名（至少两段、全小写）：$value');
  }
}

void _validatePrefix(String value) {
  if (!RegExp(r'^[A-Z][A-Za-z0-9]{0,3}$').hasMatch(value)) {
    _fail('--prefix 必须是 1–4 个字符、大写字母开头：$value');
  }
}

/// 显示名 → PascalCase，用于 Controller / Scope / State 的类名。
String _pascalOf(String appName) {
  final words = appName
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) _fail('--app-name 至少包含一个字母：$appName');
  final buffer = StringBuffer();
  for (final word in words) {
    buffer.write(word[0].toUpperCase());
    buffer.write(word.substring(1));
  }
  return buffer.toString();
}

/// 从显示名推导短前缀：多词取首字母（KeyCase → Kc），单词取前两位（Finance → Fi）。
String _derivePrefix(String appName) {
  final chunks = <String>[];
  for (final word in appName.split(RegExp(r'[^A-Za-z0-9]+'))) {
    if (word.isEmpty) continue;
    final parts = RegExp(r'[A-Z][a-z0-9]*').allMatches(word).toList();
    if (parts.length > 1) {
      chunks.addAll(parts.map((match) => match.group(0)!));
    } else {
      chunks.add(word);
    }
  }
  if (chunks.isEmpty) _fail('无法从 --app-name 推导前缀，请显式传 --prefix');
  if (chunks.length >= 2) {
    return '${chunks[0][0]}${chunks[1][0]}'.toUpperCase();
  }
  final single = chunks.first;
  return single.length >= 2
      ? '${single[0]}${single[1]}'.toUpperCase()
      : single[0].toUpperCase();
}

String _readPackageName(Directory root) {
  final pubspec = File('${root.path}/pubspec.yaml');
  if (!pubspec.existsSync()) {
    _fail('${pubspec.path} 不存在；--output 指向的目录不完整，先删掉再加 --force 重试');
  }
  final match = RegExp(
    r'^name:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  if (match == null) _fail('pubspec.yaml 里找不到 name:');
  return match.group(1)!;
}

bool _isExcluded(String relative) {
  for (final excluded in _excludedPaths) {
    if (relative == excluded || relative.startsWith('$excluded/')) return true;
  }
  if (relative.endsWith('.jks') ||
      relative.endsWith('.keystore') ||
      relative.endsWith('.base64')) {
    return true;
  }
  return false;
}

String _relativeOf(Directory root, File file) {
  final rootPath = root.path.replaceAll('\\', '/');
  return file.path.replaceAll('\\', '/').substring(rootPath.length + 1);
}

/// 复制模板（跳过构建产物、.git 与签名材料）。
void _copyTree(Directory source, Directory target) {
  for (final entry in source.listSync(recursive: true)) {
    if (entry is! File) continue;
    final relative = _relativeOf(source, entry);
    if (_isExcluded(relative)) continue;
    final destination = File('${target.path}/$relative');
    destination.parent.createSync(recursive: true);
    entry.copySync(destination.path);
  }
}

Iterable<File> _walk(Directory root) sync* {
  for (final entry in root.listSync(recursive: true)) {
    if (entry is! File) continue;
    if (_isExcluded(_relativeOf(root, entry))) continue;
    yield entry;
  }
}

bool _isTextFile(File file) {
  final name = file.path.replaceAll('\\', '/').split('/').last;
  if (_textFileNames.contains(name)) return true;
  return _textExtensions.any(name.endsWith);
}

String? _readText(File file) {
  try {
    return file.readAsStringSync();
  } on FileSystemException {
    return null;
  } on FormatException {
    return null;
  }
}

/// Kotlin 包目录随 applicationId 变化：.../kotlin/<旧组织>/<旧包名> → 新路径。
void _renameKotlinPackage(
  Directory root,
  String oldPackageName,
  String packageName,
  String org,
) {
  final kotlinRoot = Directory('${root.path}/android/app/src/main/kotlin');
  if (!kotlinRoot.existsSync()) return;

  File? activity;
  for (final entry in kotlinRoot.listSync(recursive: true)) {
    if (entry is File && entry.path.endsWith('MainActivity.kt')) {
      activity = entry;
      break;
    }
  }
  if (activity == null) return;

  final oldDir = activity.parent;
  final expectedOldPath =
      '${kotlinRoot.path}/${_templateOrg.replaceAll('.', '/')}/$oldPackageName';
  if (oldDir.path.replaceAll('\\', '/') !=
      expectedOldPath.replaceAll('\\', '/')) {
    print('! Kotlin 包目录与预期不一致，按实际位置迁移：${oldDir.path}');
  }

  final newDir = Directory(
    '${kotlinRoot.path}/${org.replaceAll('.', '/')}/$packageName',
  );
  if (oldDir.path.replaceAll('\\', '/') == newDir.path.replaceAll('\\', '/')) {
    return;
  }
  newDir.createSync(recursive: true);
  for (final entry in oldDir.listSync()) {
    if (entry is! File) continue;
    final name = entry.path.replaceAll('\\', '/').split('/').last;
    entry.copySync('${newDir.path}/$name');
    entry.deleteSync();
  }
  print('Kotlin 包目录 -> ${newDir.path.replaceAll('\\', '/')}');

  // 清掉迁移后留下的空包目录，遇到非空目录或 kotlin 根就停。
  var cursor = oldDir;
  final stop = kotlinRoot.absolute.path;
  while (cursor.path.replaceAll('\\', '/') != stop.replaceAll('\\', '/') &&
      cursor.existsSync()) {
    if (cursor.listSync().isNotEmpty) break;
    final parent = cursor.parent;
    cursor.deleteSync();
    cursor = parent;
  }
}

/// 版本号重置为 0.1.0+1。
void _resetVersion(Directory root) {
  final pubspec = File('${root.path}/pubspec.yaml');
  final updated = pubspec.readAsStringSync().replaceFirst(
    RegExp(r'^version:\s*\d+\.\d+\.\d+\+\d+\s*$', multiLine: true),
    'version: $_templateVersion+1',
  );
  pubspec.writeAsStringSync(updated);

  File('${root.path}/lib/app/app_version.dart').writeAsStringSync(
    '// 应用版本号展示文案；由 scripts/publish.dart 在发版时自动更新。\n\n'
    "const String kAppVersion = '$_templateVersion';\n"
    'const int kAppBuildNumber = 1;\n',
  );
}

void _writeChangelog(Directory root, String appName) {
  final today = DateTime.now().toIso8601String().split('T').first;
  File('${root.path}/CHANGELOG.md').writeAsStringSync('''
# Changelog

$appName 的用户可见变更记录。内部重构、测试与文档整理不写入。

## [Unreleased]

## [$_templateVersion] - $today

- 初始版本。
''');
}

void _writeReadme(Directory root, String appName, String prefix) {
  File('${root.path}/README.md').writeAsStringSync('''
<div align="center">

# $appName

<!-- TODO: 一句话说明这个 App 做什么、给谁用。 -->

![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter&logoColor=white)

</div>

## 功能

<!-- TODO: 按「用户看到什么」列功能，一行一个能力；截图放 docs/screenshots/。 -->

| 区域 | 能力 |
|---|---|
| 条目 | 新建、编辑、删除；数据持久化到本机 |

## 技术栈

| 层 | 选择 |
|---|---|
| UI | Flutter 3.47.2、Material 3、自有设计令牌（`${prefix}Page` / `${prefix}Card` / `${prefix}Header`） |
| 状态 | `ChangeNotifier` + `InheritedNotifier`，不用 Provider / Riverpod / Bloc |
| 存储 | `shared_preferences` 存带版本号的 JSON（示例）；数据变多后换 sqflite 或应用私有目录 |
| 原生桥 | 一条 `MethodChannel`：`FLAG_SECURE` 防截屏 |
| CI/CD | GitHub Actions、Flutter 3.47.2、签名 arm64 APK 与预发布 |

## 开发

```bash
flutter pub get
dart run scripts/doctor.dart
flutter run -d emulator-5554
```

- 代码规范、目录约定与完成前检查：见 [AGENTS.md](AGENTS.md)。
- 设计令牌与组件：见 [docs/design/design-system.md](docs/design/design-system.md) 与
  [docs/design/components.md](docs/design/components.md)。
- 架构与分层：见 [docs/dev/architecture.md](docs/dev/architecture.md)。
- 构建、签名与发版：见 [docs/dev/release.md](docs/dev/release.md)。

## 构建与发版

```bash
dart run tool/signing.dart                       # 首次：生成发布签名
flutter build apk --release --target-platform android-arm64
dart run scripts/publish.dart patch              # 发版需要用户明确授权
```

## 许可

见 [LICENSE](LICENSE)。
''');
}

void _deleteTemplateOnlyFiles(Directory root) {
  for (final relative in _templateOnlyFiles) {
    final file = File('${root.path}/$relative');
    if (!file.existsSync()) continue;
    try {
      file.deleteSync();
      print('已删除模板专属文件：$relative');
    } on FileSystemException {
      // 原地运行时，脚本自身可能被系统占用；删不掉就让用户手动删。
      print('! 请手动删除模板专属文件：$relative');
    }
  }
  for (final entry in root.listSync(recursive: true)) {
    if (entry is File && entry.path.endsWith('.iml')) {
      entry.deleteSync();
    }
  }
  final toolDir = Directory('${root.path}/tool');
  if (toolDir.existsSync() && toolDir.listSync().isEmpty) {
    toolDir.deleteSync();
  }
}

/// 改名后标识符长度会变，用当前 SDK 的 formatter 统一一次，保证生成即合规。
void _formatTree(Directory root) {
  final result = Process.runSync(Platform.resolvedExecutable, <String>[
    'format',
    '.',
  ], workingDirectory: root.path);
  if (result.exitCode == 0) {
    print('已用 dart format 统一格式');
  } else {
    print('! dart format 失败，请手动跑一次：${result.stderr}');
  }
}

/// 把模板视角的 SECURITY.md 换成这个 App 的版本。
void _writeSecurity(Directory root, String appName) {
  File('${root.path}/SECURITY.md').writeAsStringSync('''
# Security policy

$appName 是一个 Flutter Android 应用。发布签名材料不入库：只存在于本机 `signing/`
与 GitHub 仓库 Secrets 里；系统自动备份默认关闭，数据只能经应用自己的导出流程离开设备。

## 报告问题

用本仓库的 **private security advisory** 报告，不要开公开 issue。
报告里不要带真实数据、口令或密钥。

## 检查项

- [ ] `signing/` 已离线备份；密钥丢失将无法覆盖升级已安装的版本
- [ ] 四个 Secret 只配置在本仓库，不写进文档、日志或提交
- [ ] 新增运行时权限（相机、通知、生物识别）时说明用途，并确认只在需要时申请
- [ ] 接入网络能力时确认 `usesCleartextTraffic` 仍为 `false`
- [ ] 日志、错误提示与崩溃信息里不得出现用户明文、口令或密钥
''');
}

/// 把 AGENTS.md 里“模板本体”的自我介绍换成这个 App 的版本。
void _rewriteAgentsIntro(
  Directory root,
  String appName,
  String packageName,
  String org,
  String prefix,
) {
  final file = File('${root.path}/AGENTS.md');
  if (!file.existsSync()) return;
  final text = file.readAsStringSync();
  final pattern = RegExp(
    r'<!-- BEGIN TEMPLATE INTRO.*?-->.*?<!-- END TEMPLATE INTRO -->',
    dotAll: true,
  );
  if (!pattern.hasMatch(text)) return;
  final intro =
      '- **$appName**：Flutter Android 本地优先应用。Dart 包名 `$packageName`，'
      'applicationId `$org.$packageName`，UI 前缀 `$prefix`。';
  file.writeAsStringSync(text.replaceFirst(pattern, intro));
}
