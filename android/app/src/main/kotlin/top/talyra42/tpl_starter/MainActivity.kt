package top.talyra42.tpl_starter

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import top.talyra42.tpl_starter.widget.HomeWidgetProvider

/**
 * 原生能力的唯一入口：与 lib/app/platform/ 下的 Dart 桥一一对应。
 *
 * 新增方法时同步三处：这里、Dart 侧（native_bridge.dart / home_widget.dart）、
 * docs/dev/architecture.md 的通道表。
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

                    "updateHomeWidget" -> {
                        val title = call.argument<String>("title")
                            ?: getString(R.string.app_name)
                        val count = call.argument<Int>("count") ?: 0
                        val subtitle = call.argument<String>("subtitle") ?: ""
                        // AppWidgetManager 的调用统一切到主线程，避免在 Binder 线程碰 UI 组件。
                        runOnUiThread {
                            HomeWidgetProvider.submitAndRefresh(
                                this,
                                title,
                                count,
                                subtitle,
                            )
                            result.success(null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private companion object {
        const val CHANNEL = "tpl_starter/native"
    }
}
