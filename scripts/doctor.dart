// 环境自检：dart run scripts/doctor.dart
//
// 只读检查，不改动任何工具链。发现缺项时打印建议，由用户决定是否安装。
// 这是命令行脚本，输出就是产品本身，因此豁免 avoid_print。
// ignore_for_file: avoid_print
import 'dart:io';

import 'src/cli.dart';
import 'src/environment.dart';

Future<void> main() async {
  var failed = false;

  final root = findRepoRoot();
  info('仓库：${root.path}');

  final flutterVersion = await flutterVersionLine();
  final pinned = readCiFlutterVersion(root);
  if (flutterVersion == null) {
    error('找不到 flutter；先装 Flutter 并把 bin 加进 PATH');
    failed = true;
  } else {
    success(flutterVersion);
    if (pinned != null && !flutterVersion.contains(pinned)) {
      warn('本机 Flutter 与 CI 固定的 $pinned 不一致，analyze 结果可能不同');
    }
  }

  if (await javaAvailable()) {
    success('java 可用');
  } else {
    // Gradle 能自己找到 Android Studio 自带的 JBR，所以这里只提示不判失败；
    // 但 tool/signing.dart 需要 keytool，缺 JDK 时它会给明确错误。
    warn('PATH 上没有 java；如果 Gradle 构建失败，装 JDK 17 或 Android Studio');
  }

  final sdk = androidSdkPath(root);
  if (sdk == null) {
    warn('未找到 Android SDK（设置 ANDROID_HOME 或 android/local.properties）');
  } else {
    success('Android SDK：$sdk');
  }

  if (hasReleaseSigning(root)) {
    success('发布签名材料就位（signing/keystore.properties）');
  } else {
    warn('缺少发布签名材料：release 构建会失败，先跑 dart run tool/signing.dart');
  }

  final git = await capture(<String>['git', 'status', '--porcelain']);
  if (git == null) {
    warn('不在 git 仓库里');
  } else if (git.trim().isNotEmpty) {
    warn('工作区有未提交改动：\n$git');
  } else {
    success('工作区干净');
  }

  exit(failed ? 1 : 0);
}
