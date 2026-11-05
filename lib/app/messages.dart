import '../l10n/app_localizations.dart';
import 'app_state.dart';

/// 错误码 → 文案。新增 [TplError] 时这里必须同步，否则编译失败。

String errorText(AppLocalizations l10n, TplError error) => switch (error) {
  TplError.storageRead => l10n.errorStorageRead,
  TplError.storageWrite => l10n.errorStorageWrite,
  TplError.titleRequired => l10n.errorTitleRequired,
};

String noticeText(AppLocalizations l10n, TplNotice notice) => switch (notice) {
  TplNotice.saved => l10n.noticeSaved,
  TplNotice.deleted => l10n.noticeDeleted,
};
