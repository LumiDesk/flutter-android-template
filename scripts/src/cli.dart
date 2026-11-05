// 仓库脚本（scripts/）共用的命令行工具：找仓库根、读版本、跑外部命令、输出。
//
// 为什么脚本用 Dart 而不是 shell：Dart 是本项目必然存在的运行时（CI 固定
// Flutter 3.47.2），跨平台只有一份实现，不需要 bash/python3/PowerShell 同时正确；
// 并且 `dart format` 与 `flutter analyze` 会把 scripts/ 一起纳入质量门禁。
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// 外部命令输出统一按 UTF-8 解码（flutter 输出是 UTF-8，系统代码页解码会乱码）；
/// 遇到非法字节不抛异常，避免个别本地化命令把脚本打断。
const Encoding _utf8Lenient = Utf8Codec(allowMalformed: true);

/// 脚本执行失败。各入口脚本捕获后打印并返回非零退出码。
class ScriptException implements Exception {
  ScriptException(this.message);

  final String message;

  @override
  String toString() => message;
}

bool get _colorEnabled =>
    !Platform.environment.containsKey('NO_COLOR') && stdout.supportsAnsiEscapes;

String _paint(String text, String code) =>
    _colorEnabled ? '\u001B[${code}m$text\u001B[0m' : text;

/// 普通信息。
void info(String message) => stdout.writeln(message);

/// 阶段标题。
void step(String message) => stdout.writeln(_paint('▶ $message', '36'));

/// 成功结果。
void success(String message) => stdout.writeln(_paint('✓ $message', '32'));

/// 警告（不阻断）。
void warn(String message) => stdout.writeln(_paint('! $message', '33'));

/// 失败信息（写 stderr）。
void error(String message) => stderr.writeln(_paint('✗ $message', '31'));

/// 从当前目录向上寻找包含 pubspec.yaml 的目录。
Directory findRepoRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw ScriptException('未找到仓库根目录；请在仓库内运行本脚本。');
    }
    dir = parent;
  }
}

/// pubspec.yaml 里的 `name:`。
String readPackageName(Directory root) {
  final text = File(p.join(root.path, 'pubspec.yaml')).readAsStringSync();
  final match = RegExp(r'^name:\s*(\S+)\s*$', multiLine: true).firstMatch(text);
  if (match == null) {
    throw ScriptException('pubspec.yaml 里找不到 name:');
  }
  return match.group(1)!;
}

/// pubspec.yaml 里的 `version: X.Y.Z+N`。
({int major, int minor, int patch, int build}) readVersion(Directory root) {
  final text = File(p.join(root.path, 'pubspec.yaml')).readAsStringSync();
  final match = RegExp(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    multiLine: true,
  ).firstMatch(text);
  if (match == null) {
    throw ScriptException('pubspec.yaml 里找不到 version: X.Y.Z+N');
  }
  return (
    major: int.parse(match.group(1)!),
    minor: int.parse(match.group(2)!),
    patch: int.parse(match.group(3)!),
    build: int.parse(match.group(4)!),
  );
}

/// 从 .github/workflows/*.yml 读 CI 固定的 Flutter 版本（单一事实来源）。
String? readCiFlutterVersion(Directory root) {
  final dir = Directory(p.join(root.path, '.github', 'workflows'));
  if (!dir.existsSync()) return null;
  final files = dir.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    if (!file.path.endsWith('.yml') && !file.path.endsWith('.yaml')) continue;
    final match = RegExp(r"flutter-version:\s*'?([0-9]+\.[0-9]+\.[0-9]+)'?")
        .firstMatch(file.readAsStringSync());
    if (match != null) return match.group(1);
  }
  return null;
}

/// 跑外部命令；[allowFailure] 为 false 时非零退出码直接抛出。
Future<ProcessResult> run(
  List<String> command, {
  String? workingDirectory,
  bool allowFailure = false,
}) async {
  // Windows 上 flutter/dart 是 .bat，必须交给 shell 解析，否则 Process.run 找不到文件。
  // 固定用 UTF-8 解码：flutter 输出 UTF-8，默认按系统代码页解码会出现乱码。
  final result = await Process.run(
    command.first,
    command.sublist(1),
    runInShell: true,
    workingDirectory: workingDirectory,
    stdoutEncoding: _utf8Lenient,
    stderrEncoding: _utf8Lenient,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (!allowFailure && result.exitCode != 0) {
    throw ScriptException('命令失败（退出码 ${result.exitCode}）: ${command.join(' ')}');
  }
  return result;
}

/// 捕获命令输出，失败返回 null。
Future<String?> capture(List<String> command) async {
  try {
    final result = await Process.run(
      command.first,
      command.sublist(1),
      runInShell: true,
      stdoutEncoding: _utf8Lenient,
      stderrEncoding: _utf8Lenient,
    );
    if (result.exitCode != 0) return null;
    return '${result.stdout}${result.stderr}';
  } on ProcessException {
    return null;
  }
}
