// 本机工具链探测：Flutter、Java、Android SDK、签名材料。
//
// 这里只做「发现 + 判定」，不做安装；安装步骤见 docs/dev/android-development.md。
import 'dart:io';

import 'package:path/path.dart' as p;

import 'cli.dart';

/// PATH 上的 flutter 版本（`flutter --version` 的第一行）。
Future<String?> flutterVersionLine() async {
  final output = await capture(<String>['flutter', '--version']);
  if (output == null || output.trim().isEmpty) return null;
  return output.split('\n').first.trim();
}

/// PATH 上的 java 是否可用。
Future<bool> javaAvailable() async {
  final output = await capture(<String>['java', '-version']);
  return output != null;
}

/// Android SDK 根目录：先看环境变量，再看 android/local.properties。
String? androidSdkPath(Directory root) {
  final fromEnv =
      Platform.environment['ANDROID_HOME'] ??
      Platform.environment['ANDROID_SDK_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  final localProperties = File(
    p.join(root.path, 'android', 'local.properties'),
  );
  if (!localProperties.existsSync()) return null;
  for (final line in localProperties.readAsLinesSync()) {
    if (line.startsWith('sdk.dir=')) {
      return line.substring('sdk.dir='.length).trim();
    }
  }
  return null;
}

/// 发布签名材料是否就位（signing/keystore.properties 与对应的 .jks）。
bool hasReleaseSigning(Directory root) {
  final properties = File(p.join(root.path, 'signing', 'keystore.properties'));
  return properties.existsSync();
}
