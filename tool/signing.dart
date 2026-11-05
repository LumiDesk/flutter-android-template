// 生成发布签名材料（本机一次性动作）：
//
//   dart run tool/signing.dart [--alias app] [--force]
//
// 产物（都在 .gitignore 里，不入库）：
//   signing/release.jks           签名密钥
//   signing/keystore.properties   Gradle 读取的属性文件
//   signing/release.jks.base64    CI 用（gh secret set 读它）
//
// 密钥丢了就再也无法用同一个 applicationId 覆盖安装/升级，务必自行备份。
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  final options = <String, String>{};
  var force = false;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--force') {
      force = true;
    } else if (arg.startsWith('--')) {
      if (i + 1 >= args.length) _fail('$arg 缺少值');
      options[arg.substring(2)] = args[++i];
    } else {
      _fail('未知参数：$arg');
    }
  }

  final root = _findRepoRoot();
  final signingDir = Directory('${root.path}/signing')
    ..createSync(recursive: true);
  final keystore = File('${signingDir.path}/release.jks');
  final properties = File('${signingDir.path}/keystore.properties');

  if ((keystore.existsSync() || properties.existsSync()) && !force) {
    _fail(
      '签名材料已存在（${keystore.path}）。\n'
      '覆盖会让已安装的旧版本无法升级安装，确认要换密钥时加 --force。',
    );
  }

  final keytool = _findKeytool();
  if (keytool == null) {
    _fail(
      '找不到 keytool。\n'
      '装 JDK 17（或 Android Studio 自带的 JBR），并让 keytool 出现在 PATH 或 JAVA_HOME/bin 里。',
    );
  }

  final alias = options['alias'] ?? 'app';
  final packageName = _readPackageName(root);
  final password = _randomPassword();
  final dname = 'CN=$packageName, O=$packageName, C=CN';

  print('▶ 生成签名密钥：${keystore.path}');
  final result = await Process.run(keytool, <String>[
    '-genkeypair',
    '-v',
    '-keystore',
    keystore.path,
    '-alias',
    alias,
    '-keyalg',
    'RSA',
    '-keysize',
    '2048',
    '-validity',
    '10000',
    '-storepass',
    password,
    '-keypass',
    password,
    '-dname',
    dname,
  ]);
  if (result.exitCode != 0) {
    stderr.write(result.stdout);
    stderr.write(result.stderr);
    _fail('keytool 执行失败（退出码 ${result.exitCode}）');
  }

  // storeFile 相对仓库根，与 android/app/build.gradle.kts 的读取方式一致。
  properties.writeAsStringSync(
    'storeFile=signing/release.jks\n'
    'storePassword=$password\n'
    'keyAlias=$alias\n'
    'keyPassword=$password\n',
  );

  final base64File = File('${signingDir.path}/release.jks.base64');
  base64File.writeAsStringSync(base64Encode(keystore.readAsBytesSync()));

  print('');
  print('✓ 已生成：');
  print('  ${keystore.path}');
  print('  ${properties.path}');
  print('  ${base64File.path}');
  print('');
  print('下一步：把签名材料写进 GitHub 仓库 Secrets（Settings → Secrets → Actions）：');
  print('  gh secret set KEYSTORE_BASE64 < "${base64File.path}"');
  print('  gh secret set KEYSTORE_PASSWORD --body "$password"');
  print('  gh secret set KEY_ALIAS --body "$alias"');
  print('  gh secret set KEY_PASSWORD --body "$password"');
  print('');
  print('备忘：');
  print('  - 把 signing/ 整个目录离线备份一份；密钥丢了就不能覆盖升级。');
  print('  - release.jks.base64 与密码等同于私钥，不要提交、不要贴进 issue。');
  print('  - 换机器时把 signing/ 拷过去即可，不需要重新生成。');
}

String _randomPassword() {
  final random = Random.secure();
  final bytes = List<int>.generate(18, (_) => random.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}

Directory _findRepoRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      _fail('未找到仓库根目录；请在仓库内运行本脚本。');
    }
    dir = parent;
  }
}

String _readPackageName(Directory root) {
  final match = RegExp(
    r'^name:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(File('${root.path}/pubspec.yaml').readAsStringSync());
  if (match == null) _fail('pubspec.yaml 里找不到 name:');
  return match.group(1)!;
}

Never _fail(String message) {
  stderr.writeln('✗ $message');
  exit(1);
}

/// 依次在 PATH、JAVA_HOME、flutter doctor 报告的 JDK、常见安装路径里找 keytool。
String? _findKeytool() {
  final exe = Platform.isWindows ? 'keytool.exe' : 'keytool';
  final separator = Platform.isWindows ? ';' : ':';

  for (final dir in (Platform.environment['PATH'] ?? '').split(separator)) {
    final candidate = File('$dir/$exe');
    if (candidate.existsSync()) return candidate.path;
  }

  final javaHome = Platform.environment['JAVA_HOME'];
  if (javaHome != null && javaHome.isNotEmpty) {
    final candidate = File('$javaHome/bin/$exe');
    if (candidate.existsSync()) return candidate.path;
  }

  final fromFlutter = _javaFromFlutterDoctor();
  if (fromFlutter != null) {
    final candidate = File('${File(fromFlutter).parent.path}/$exe');
    if (candidate.existsSync()) return candidate.path;
  }

  for (final base in <String>[
    r'C:\Program Files\Android\Android Studio\jbr\bin',
    r'C:\Program Files\Android\Android Studio\jre\bin',
    '/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin',
    '${Platform.environment['HOME'] ?? ''}/android-studio/jbr/bin',
  ]) {
    final candidate = File('$base/$exe');
    if (candidate.existsSync()) return candidate.path;
  }
  return null;
}

/// `flutter doctor -v` 里的 "Java binary at: .../bin/java" 是最可靠的 JDK 来源。
String? _javaFromFlutterDoctor() {
  try {
    final result = Process.runSync('flutter', <String>[
      'doctor',
      '-v',
    ], runInShell: true);
    final output = '${result.stdout}${result.stderr}';
    final match = RegExp(
      r'Java binary at:\s*(.+?)\s*$',
      multiLine: true,
    ).firstMatch(output);
    return match?.group(1)?.trim();
  } on ProcessException {
    return null;
  }
}
