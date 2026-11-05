package top.talyra42.tpl_starter.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import top.talyra42.tpl_starter.MainActivity
import top.talyra42.tpl_starter.R

/**
 * 桌面小组件：只读一份由应用写好的摘要，用 RemoteViews 渲染。
 *
 * 刻意不在这里跑 Flutter、不开后台 isolate、不做定时轮询：
 * 组件在系统进程里被拉起的时机和次数都不可控，做重活就会被杀、被限频。
 * 数据流是单向的：Dart 写摘要 → 这里读摘要 → 更新所有实例。
 */
class HomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(id, buildViews(context))
        }
    }

    /** 首次添加或系统重启后，也要拿一次当前数据。 */
    override fun onEnabled(context: Context) {
        refreshAll(context)
    }

    companion object {
        private const val PREFS = "tpl_home_widget"
        private const val KEY_TITLE = "title"
        private const val KEY_COUNT = "count"
        private const val KEY_SUBTITLE = "subtitle"

        /** 由 Dart 经 MethodChannel 调用：写入摘要并刷新所有实例。 */
        fun submitAndRefresh(
            context: Context,
            title: String,
            count: Int,
            subtitle: String,
        ) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_TITLE, title)
                .putInt(KEY_COUNT, count)
                .putString(KEY_SUBTITLE, subtitle)
                .apply()
            refreshAll(context)
        }

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context) ?: return
            val ids = manager.getAppWidgetIds(
                ComponentName(context, HomeWidgetProvider::class.java),
            )
            if (ids.isEmpty()) return
            val views = buildViews(context)
            ids.forEach { manager.updateAppWidget(it, views) }
        }

        private fun buildViews(context: Context): RemoteViews {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.widget_home)

            views.setTextViewText(
                R.id.widget_title,
                prefs.getString(KEY_TITLE, null) ?: context.getString(R.string.app_name),
            )
            views.setTextViewText(
                R.id.widget_count,
                prefs.getInt(KEY_COUNT, 0).toString(),
            )
            views.setTextViewText(
                R.id.widget_subtitle,
                prefs.getString(KEY_SUBTITLE, null)
                    ?: context.getString(R.string.widget_empty),
            )

            // Android 12+ 要求 PendingIntent 显式指定可变性。
            val intent = Intent(context, MainActivity::class.java)
            val pending = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            return views
        }
    }
}
