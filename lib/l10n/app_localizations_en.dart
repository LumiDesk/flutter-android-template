// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tpl Starter';

  @override
  String get navHome => 'Items';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'All items';

  @override
  String homeSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'No items yet';

  @override
  String get homeEmptyDescription =>
      'Use the button at the bottom right to add the first one.';

  @override
  String get homeEmptyAction => 'Add item';

  @override
  String get itemDeleteConfirmTitle => 'Delete this item?';

  @override
  String itemDeleteConfirmMessage(String title) {
    return '\"$title\" will be deleted. This cannot be undone.';
  }

  @override
  String get editorTitleNew => 'New item';

  @override
  String get editorTitleEdit => 'Edit item';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldTitleHint => 'Name this item';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldNoteHint => 'Optional, multiple lines';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionAbout => 'About';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsAccent => 'Accent';

  @override
  String get accentSystem => 'System';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentTeal => 'Teal';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentAmber => 'Amber';

  @override
  String get accentPink => 'Pink';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsSecureScreen => 'Block screenshots';

  @override
  String get settingsSecureScreenSubtitle =>
      'Screenshots and screen recording show a black frame';

  @override
  String get settingsLogs => 'App logs';

  @override
  String get settingsLogsSubtitle => 'Keeps the last 200 entries in memory';

  @override
  String get logsTitle => 'App logs';

  @override
  String get logsEmpty => 'No log entries yet';

  @override
  String get settingsVersion => 'Version';

  @override
  String get actionBack => 'Back';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionClose => 'Close';

  @override
  String get errorStorageRead =>
      'Could not read local data; showing an empty list';

  @override
  String get errorStorageWrite => 'Save failed; your change may not be stored';

  @override
  String get errorTitleRequired => 'Title cannot be empty';

  @override
  String get noticeSaved => 'Saved';

  @override
  String get noticeDeleted => 'Deleted';
}
