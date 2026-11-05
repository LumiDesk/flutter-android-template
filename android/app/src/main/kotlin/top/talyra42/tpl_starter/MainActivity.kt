package top.talyra42.tpl_starter

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 原生能力的唯一入口：与 lib/app/platform/native_bridge.dart 一一对应。
 *
 * 新增方法时同步三处：这里、Dart 侧的 NativeBridge、docs/dev/architecture.md。
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecureScreen" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: true
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private companion object {
        const val CHANNEL = "tpl_starter/native"
    }
}
