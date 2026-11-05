import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../app/app_version.dart';
import '../app/models/preferences.dart';
import '../common_widgets.dart';
import '../l10n/app_localizations.dart';
import 'log_page.dart';

/// 设置页：主题、强调色、语言、防截屏、版本。
///
/// 所有单选都用 [TplMenuRow]（锚点菜单），不要另写分段控件或底部单选弹层。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TplScope.of(context);
    final preferences = controller.preferences;
    final l10n = AppLocalizations.of(context);
    final accentValue = preferences.colorMode == ThemeColorMode.system
        ? -1
        : preferences.accentIndex;

    return Scaffold(
      body: SafeArea(
        child: TplPage(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[
              TplHeader(title: l10n.settingsTitle),
              TplSectionLabel(l10n.sectionAppearance),
              TplCard(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    TplMenuRow<ThemeModePreference>(
                      title: l10n.settingsTheme,
                      icon: Icons.brightness_6_outlined,
                      value: _themeLabel(l10n, preferences.themeMode),
                      values: ThemeModePreference.values,
                      selected: preferences.themeMode,
                      labelOf: (mode) => _themeLabel(l10n, mode),
                      onSelected: controller.setThemeMode,
                      keyPrefix: 'tpl_theme',
                    ),
                    const TplRowDivider(),
                    TplMenuRow<int>(
                      title: l10n.settingsAccent,
                      icon: Icons.palette_outlined,
                      value: accentValue < 0
                          ? l10n.accentSystem
                          : _accentLabel(l10n, accentValue),
                      trailingColor: accentValue < 0
                          ? null
                          : tplAccentPresets[accentValue.clamp(
                              0,
                              tplAccentPresets.length - 1,
                            )],
                      values: <int>[-1, 0, 1, 2, 3, 4],
                      selected: accentValue,
                      labelOf: (index) => index < 0
                          ? l10n.accentSystem
                          : _accentLabel(l10n, index),
                      onSelected: (index) =>
                          controller.setAccent(index < 0 ? null : index),
                      keyPrefix: 'tpl_accent',
                    ),
                  ],
                ),
              ),
              TplSectionLabel(l10n.sectionGeneral),
              TplCard(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    TplMenuRow<String>(
                      title: l10n.settingsLanguage,
                      icon: Icons.translate_rounded,
                      value: _languageLabel(l10n, preferences.languageCode),
                      values: const <String>['', 'zh', 'en'],
                      selected: preferences.languageCode,
                      // 空串表示跟随系统；菜单项 id 不能为空，单独映射一次。
                      idOf: (code) => code.isEmpty ? 'system' : code,
                      labelOf: (code) => _languageLabel(l10n, code),
                      onSelected: controller.setLanguageCode,
                      keyPrefix: 'tpl_language',
                    ),
                    const TplRowDivider(),
                    TplSwitchRow(
                      icon: Icons.screenshot_monitor_outlined,
                      title: l10n.settingsSecureScreen,
                      subtitle: l10n.settingsSecureScreenSubtitle,
                      value: preferences.secureScreen,
                      onChanged: controller.setSecureScreen,
                    ),
                    const TplRowDivider(),
                    TplSettingsRow(
                      icon: Icons.article_outlined,
                      title: l10n.settingsLogs,
                      subtitle: l10n.settingsLogsSubtitle,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const LogPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TplSectionLabel(l10n.sectionAbout),
              TplCard(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TplKeyValueRow(
                  label: l10n.settingsVersion,
                  value: 'v$kAppVersion+$kAppBuildNumber',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _themeLabel(AppLocalizations l10n, ThemeModePreference mode) {
    return switch (mode) {
      ThemeModePreference.system => l10n.themeSystem,
      ThemeModePreference.light => l10n.themeLight,
      ThemeModePreference.dark => l10n.themeDark,
    };
  }

  static String _accentLabel(AppLocalizations l10n, int index) {
    return switch (index) {
      0 => l10n.accentBlue,
      1 => l10n.accentTeal,
      2 => l10n.accentGreen,
      3 => l10n.accentAmber,
      _ => l10n.accentPink,
    };
  }

  static String _languageLabel(AppLocalizations l10n, String code) {
    return switch (code) {
      'zh' => l10n.languageChinese,
      'en' => l10n.languageEnglish,
      _ => l10n.languageSystem,
    };
  }
}
