// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Tpl Starter';

  @override
  String get navHome => '条目';

  @override
  String get navSettings => '设置';

  @override
  String get homeTitle => '所有条目';

  @override
  String homeSubtitle(int count) {
    return '$count 条';
  }

  @override
  String get homeEmptyTitle => '还没有条目';

  @override
  String get homeEmptyDescription => '点右下角的按钮添加第一条。';

  @override
  String get homeEmptyAction => '添加条目';

  @override
  String get itemDeleteConfirmTitle => '删除这条？';

  @override
  String itemDeleteConfirmMessage(String title) {
    return '「$title」将被删除，此操作不可撤销。';
  }

  @override
  String get editorTitleNew => '新建条目';

  @override
  String get editorTitleEdit => '编辑条目';

  @override
  String get fieldTitle => '标题';

  @override
  String get fieldTitleHint => '给这条起个名字';

  @override
  String get fieldNote => '备注';

  @override
  String get fieldNoteHint => '可选，支持多行';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionGeneral => '通用';

  @override
  String get sectionAbout => '关于';

  @override
  String get settingsTheme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get settingsAccent => '强调色';

  @override
  String get accentSystem => '跟随系统';

  @override
  String get accentBlue => '蓝';

  @override
  String get accentTeal => '青';

  @override
  String get accentGreen => '绿';

  @override
  String get accentAmber => '琥珀';

  @override
  String get accentPink => '粉';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsSecureScreen => '防截屏';

  @override
  String get settingsSecureScreenSubtitle => '开启后系统截屏与录屏会显示黑屏';

  @override
  String get settingsLogs => '应用日志';

  @override
  String get settingsLogsSubtitle => '只在内存里保留最近 200 条';

  @override
  String get logsTitle => '应用日志';

  @override
  String get logsEmpty => '还没有日志';

  @override
  String get settingsVersion => '版本';

  @override
  String get actionBack => '返回';

  @override
  String get actionAdd => '添加';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '删除';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionClose => '关闭';

  @override
  String get errorStorageRead => '读取本地数据失败，已回退到空列表';

  @override
  String get errorStorageWrite => '保存失败，改动可能没有写入';

  @override
  String get errorTitleRequired => '标题不能为空';

  @override
  String get noticeSaved => '已保存';

  @override
  String get noticeDeleted => '已删除';
}
