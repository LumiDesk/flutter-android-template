import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'Tpl Starter'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'条目'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get navSettings;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'所有条目'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条'**
  String homeSubtitle(int count);

  /// No description provided for @homeEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有条目'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyDescription.
  ///
  /// In zh, this message translates to:
  /// **'点右下角的按钮添加第一条。'**
  String get homeEmptyDescription;

  /// No description provided for @homeEmptyAction.
  ///
  /// In zh, this message translates to:
  /// **'添加条目'**
  String get homeEmptyAction;

  /// No description provided for @itemDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除这条？'**
  String get itemDeleteConfirmTitle;

  /// No description provided for @itemDeleteConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'「{title}」将被删除，此操作不可撤销。'**
  String itemDeleteConfirmMessage(String title);

  /// No description provided for @editorTitleNew.
  ///
  /// In zh, this message translates to:
  /// **'新建条目'**
  String get editorTitleNew;

  /// No description provided for @editorTitleEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑条目'**
  String get editorTitleEdit;

  /// No description provided for @fieldTitle.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get fieldTitle;

  /// No description provided for @fieldTitleHint.
  ///
  /// In zh, this message translates to:
  /// **'给这条起个名字'**
  String get fieldTitleHint;

  /// No description provided for @fieldNote.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get fieldNote;

  /// No description provided for @fieldNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'可选，支持多行'**
  String get fieldNoteHint;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get sectionAppearance;

  /// No description provided for @sectionGeneral.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get sectionGeneral;

  /// No description provided for @sectionAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get sectionAbout;

  /// No description provided for @settingsTheme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @settingsAccent.
  ///
  /// In zh, this message translates to:
  /// **'强调色'**
  String get settingsAccent;

  /// No description provided for @accentSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get accentSystem;

  /// No description provided for @accentBlue.
  ///
  /// In zh, this message translates to:
  /// **'蓝'**
  String get accentBlue;

  /// No description provided for @accentTeal.
  ///
  /// In zh, this message translates to:
  /// **'青'**
  String get accentTeal;

  /// No description provided for @accentGreen.
  ///
  /// In zh, this message translates to:
  /// **'绿'**
  String get accentGreen;

  /// No description provided for @accentAmber.
  ///
  /// In zh, this message translates to:
  /// **'琥珀'**
  String get accentAmber;

  /// No description provided for @accentPink.
  ///
  /// In zh, this message translates to:
  /// **'粉'**
  String get accentPink;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageSystem;

  /// No description provided for @languageChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsSecureScreen.
  ///
  /// In zh, this message translates to:
  /// **'防截屏'**
  String get settingsSecureScreen;

  /// No description provided for @settingsSecureScreenSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开启后系统截屏与录屏会显示黑屏'**
  String get settingsSecureScreenSubtitle;

  /// No description provided for @settingsLogs.
  ///
  /// In zh, this message translates to:
  /// **'应用日志'**
  String get settingsLogs;

  /// No description provided for @settingsLogsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'只在内存里保留最近 200 条'**
  String get settingsLogsSubtitle;

  /// No description provided for @logsTitle.
  ///
  /// In zh, this message translates to:
  /// **'应用日志'**
  String get logsTitle;

  /// No description provided for @logsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有日志'**
  String get logsEmpty;

  /// No description provided for @settingsVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get settingsVersion;

  /// No description provided for @actionBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get actionBack;

  /// No description provided for @actionAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get actionAdd;

  /// No description provided for @actionSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get actionEdit;

  /// No description provided for @actionClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get actionClose;

  /// No description provided for @errorStorageRead.
  ///
  /// In zh, this message translates to:
  /// **'读取本地数据失败，已回退到空列表'**
  String get errorStorageRead;

  /// No description provided for @errorStorageWrite.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，改动可能没有写入'**
  String get errorStorageWrite;

  /// No description provided for @errorTitleRequired.
  ///
  /// In zh, this message translates to:
  /// **'标题不能为空'**
  String get errorTitleRequired;

  /// No description provided for @noticeSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get noticeSaved;

  /// No description provided for @noticeDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get noticeDeleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
