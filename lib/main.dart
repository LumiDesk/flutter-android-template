import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_controller.dart';
import 'app/app_scope.dart';
import 'app/app_state.dart';
import 'app/app_theme.dart';
import 'app/feedback.dart';
import 'app/logging/app_logger.dart';
import 'app/messages.dart';
import 'app/models/preferences.dart';
import 'app/platform/native_bridge.dart';
import 'l10n/app_localizations.dart';
import 'pages/app_shell.dart';

/// 按 Flutter 的标准 locale 解析规则选择应用文案。
///
/// 设备常给出 `zh_CN`，而 ARB 只有 `zh`；不能用 `supportedLocales.contains`
/// 直接判断，否则会错误回退到英文。
AppLocalizations resolveAppLocalizations(Locale locale) {
  final resolved = basicLocaleListResolution(<Locale>[
    locale,
  ], AppLocalizations.supportedLocales);
  return lookupAppLocalizations(resolved);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error('flutter error', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('uncaught error', error, stack);
    return true;
  };
  final controller = TplController();
  await controller.bootstrap();
  // 防截屏是加固项：失败只记日志，不影响启动。
  unawaited(NativeBridge.setSecureScreen(controller.preferences.secureScreen));
  runApp(TplApp(controller: controller));
}

class TplApp extends StatefulWidget {
  const TplApp({super.key, required this.controller});

  final TplController controller;

  @override
  State<TplApp> createState() => _TplAppState();
}

class _TplAppState extends State<TplApp> {
  final TplFeedbackController _feedback = TplFeedbackController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChange);
    _feedback.dispose();
    super.dispose();
  }

  /// 一次性提示与错误统一在这里消费：走轻反馈，然后清空状态里的标志。
  void _handleStateChange() {
    final state = widget.controller.state;
    final l10n = _localizations();

    if (state.notice != null) {
      _feedback.show(noticeText(l10n, state.notice!));
      widget.controller.clearNotice();
    }
    if (state.error != null) {
      _feedback.show(errorText(l10n, state.error!));
      widget.controller.clearError();
    }
  }

  AppLocalizations _localizations() {
    final language = widget.controller.preferences.languageCode;
    final locale = language.isEmpty
        ? WidgetsBinding.instance.platformDispatcher.locale
        : Locale(language);
    return resolveAppLocalizations(locale);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final preferences = widget.controller.preferences;
        return MaterialApp(
          title: 'Tpl Starter',
          debugShowCheckedModeBanner: false,
          theme: buildTplTheme(
            brightness: Brightness.light,
            preferences: preferences,
          ),
          darkTheme: buildTplTheme(
            brightness: Brightness.dark,
            preferences: preferences,
          ),
          themeMode: switch (preferences.themeMode) {
            ThemeModePreference.system => ThemeMode.system,
            ThemeModePreference.light => ThemeMode.light,
            ThemeModePreference.dark => ThemeMode.dark,
          },
          locale: preferences.languageCode.isEmpty
              ? null
              : Locale(preferences.languageCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return TplFeedbackHost(
              controller: _feedback,
              child: TplScope(
                controller: widget.controller,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: const _RootGate(),
        );
      },
    );
  }
}

/// 启动页 → 主界面。真实项目里这里通常还要接「未解锁 / 空库 / 已登录」等分支。
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final status = TplScope.of(context).state.status;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (status) {
        TplStatus.loading => const _BootSplash(),
        TplStatus.ready => const AppShell(),
      },
    );
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 42,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
