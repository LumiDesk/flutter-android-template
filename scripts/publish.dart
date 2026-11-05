// 发版脚本：dart run scripts/publish.dart patch|minor|major|X.Y.Z [--dry-run]
//
// 脚本只做「改版本号 → 格式化 → analyze → test → 提交 → 打标签 → 推送」，
// 签名构建与发布由 .github/workflows/release.yml 完成。
// 打标签会触发远端 CI，因此必须由用户明确要求后才能执行。
// 这是命令行脚本，输出就是产品本身，因此豁免 avoid_print。
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:path/path.dart' as p;

import 'src/cli.dart';

Future<void> main(List<String> args) async {
  try {
    await _publish(args);
  } on ScriptException catch (exception) {
    error(exception.message);
    exit(1);
  }
}

Future<void> _publish(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final positional = args.where((arg) => !arg.startsWith('--')).toList();
  if (positional.isEmpty) {
    stderr.writeln(
      '用法: dart run scripts/publish.dart patch|minor|major|X.Y.Z [--dry-run]',
    );
    exit(64);
  }

  final root = findRepoRoot();
  final name = readPackageName(root);
  final current = readVersion(root);

  final (int, int, int) next;
  switch (positional.first) {
    case 'major':
      next = (current.major + 1, 0, 0);
    case 'minor':
      next = (current.major, current.minor + 1, 0);
    case 'patch':
      next = (current.major, current.minor, current.patch + 1);
    default:
      final parts = positional.first.split('.');
      if (parts.length != 3) {
        stderr.writeln('版本号必须是 patch / minor / major 或 X.Y.Z');
        exit(64);
      }
      next = (int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  final version = '${next.$1}.${next.$2}.${next.$3}';
  final nextBuild = current.build + 1;
  info(
    '$name: ${current.major}.${current.minor}.${current.patch}+${current.build} '
    '-> $version+$nextBuild',
  );

  // 发布说明与 CHANGELOG 是发版的必填项，缺文件时在改版本号之前就停下。
  _checkReleaseMaterials(root, version);

  if (dryRun) {
    success('--dry-run：跳过写入、提交与推送');
    return;
  }

  final status = await capture(<String>['git', 'status', '--porcelain']);
  if (status == null) {
    throw ScriptException('不在 git 仓库里');
  }
  if (status.trim().isNotEmpty) {
    throw ScriptException('工作区不干净，先提交或清理再发版：\n$status');
  }

  _writeVersion(root, version, nextBuild);

  await run(<String>['dart', 'format', '.']);
  await run(<String>['flutter', 'analyze']);
  await run(<String>['flutter', 'test']);
  await run(<String>['git', 'add', 'pubspec.yaml', 'lib/app/app_version.dart']);
  await run(<String>['git', 'commit', '-m', 'chore: release v$version']);
  await run(<String>['git', 'tag', 'v$version']);
  await run(<String>['git', 'push', 'origin', 'HEAD']);
  await run(<String>['git', 'push', 'origin', 'v$version']);

  success('已推送 v$version，CI 会构建签名 APK 并创建预发布。');
  info('真机验收通过后提升为 Latest：');
  info('  gh release edit v$version --prerelease=false --latest');
}

/// 发版前的必填项检查：CHANGELOG 段与发布说明文件，规则见 docs/dev/release.md。
void _checkReleaseMaterials(Directory root, String version) {
  final notes = File(
    p.join(root.path, 'docs', 'release-notes', 'v$version.md'),
  );
  if (!notes.existsSync() || notes.lengthSync() == 0) {
    throw ScriptException(
      '缺少发布说明：docs/release-notes/v$version.md\n'
      '先按 docs/dev/release.md 的模板写好，再执行发版。',
    );
  }
  final changelog = File(p.join(root.path, 'CHANGELOG.md'));
  if (!changelog.existsSync() ||
      !changelog.readAsStringSync().contains('## [$version]')) {
    throw ScriptException('CHANGELOG.md 缺少 ## [$version] 段，先记录用户可见变更。');
  }
}

/// 改 pubspec.yaml 与 lib/app/app_version.dart 两处版本号。
void _writeVersion(Directory root, String version, int build) {
  final pubspec = File(p.join(root.path, 'pubspec.yaml'));
  final text = pubspec.readAsStringSync();
  final updated = text.replaceFirst(
    RegExp(r'^version:\s*\d+\.\d+\.\d+\+\d+\s*$', multiLine: true),
    'version: $version+$build',
  );
  pubspec.writeAsStringSync(updated);

  final appVersion = File(p.join(root.path, 'lib', 'app', 'app_version.dart'));
  appVersion.writeAsStringSync(
    "// 应用版本号展示文案；由 scripts/publish.dart 在发版时自动更新。\n\n"
    "const String kAppVersion = '$version';\n"
    'const int kAppBuildNumber = $build;\n',
  );
}
