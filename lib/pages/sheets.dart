import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../l10n/app_localizations.dart';

/// 弹层统一入口。
///
/// 页面不得裸写 `showModalBottomSheet`：圆角、拖拽把手、安全区与最大高度必须
/// 一致，否则不同页面会出现多套观感。
Future<T?> showTplSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  final theme = Theme.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: tplElevatedSurfaceColor(theme.brightness),
    showDragHandle: true,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tplRadiusXl)),
    ),
    constraints: const BoxConstraints(maxWidth: tplPageMaxWidth),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: builder(sheetContext),
      );
    },
  );
}

/// 二次确认。破坏性操作传 `destructive: true`，按钮会变成警示色。
Future<bool> showTplConfirm({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        backgroundColor: tplElevatedSurfaceColor(theme.brightness),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tplRadiusXl),
        ),
        title: Text(title, style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: tplSemantic(context, tplDanger),
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel ?? l10n.actionDelete),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// 单行/多行文本输入（重命名、备注等）。取消返回 null。
Future<String?> showTplTextInput({
  required BuildContext context,
  required String title,
  String? initialValue,
  String? hint,
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return showTplSheet<String>(
    context: context,
    builder: (sheetContext) {
      return _TextInputSheet(
        title: title,
        initialValue: initialValue,
        hint: hint,
        maxLines: maxLines,
        keyboardType: keyboardType,
      );
    },
  );
}

class _TextInputSheet extends StatefulWidget {
  const _TextInputSheet({
    required this.title,
    this.initialValue,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String title;
  final String? initialValue;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(hintText: widget.hint),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.actionCancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_controller.text),
                  child: Text(l10n.actionSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
