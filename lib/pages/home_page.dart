import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/models/item.dart';
import '../common_widgets.dart';
import '../l10n/app_localizations.dart';
import 'sheets.dart';

/// 列表页：空状态 / 列表 / 新增 / 编辑 / 删除四条主链路的最小实现。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _create(BuildContext context) async {
    final controller = TplScope.of(context);
    final l10n = AppLocalizations.of(context);
    final draft = await showTplEditor(context, title: l10n.editorTitleNew);
    if (draft == null) return;
    await controller.addItem(title: draft.title, note: draft.note);
  }

  Future<void> _edit(BuildContext context, Item item) async {
    final controller = TplScope.of(context);
    final l10n = AppLocalizations.of(context);
    final draft = await showTplEditor(
      context,
      title: l10n.editorTitleEdit,
      item: item,
    );
    if (draft == null) return;
    await controller.updateItem(item.id, title: draft.title, note: draft.note);
  }

  Future<void> _delete(BuildContext context, Item item) async {
    final controller = TplScope.of(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showTplConfirm(
      context: context,
      title: l10n.itemDeleteConfirmTitle,
      message: l10n.itemDeleteConfirmMessage(item.title),
      destructive: true,
    );
    if (!confirmed) return;
    await controller.deleteItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = TplScope.of(context).state;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: TplPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TplHeader(
                title: l10n.homeTitle,
                subtitle: state.items.isEmpty
                    ? null
                    : l10n.homeSubtitle(state.items.length),
                actions: <Widget>[
                  IconButton(
                    onPressed: () => _create(context),
                    icon: const Icon(Icons.add_rounded),
                    tooltip: l10n.actionAdd,
                  ),
                ],
              ),
              Expanded(
                child: state.items.isEmpty
                    ? TplEmptyState(
                        icon: Icons.inbox_rounded,
                        title: l10n.homeEmptyTitle,
                        description: l10n.homeEmptyDescription,
                        action: FilledButton(
                          onPressed: () => _create(context),
                          child: Text(l10n.homeEmptyAction),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        itemCount: state.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _ItemTile(
                            key: ValueKey<String>(item.id),
                            item: item,
                            onTap: () => _edit(context, item),
                            onDelete: () => _delete(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return TplCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          TplLetterAvatar(seed: item.title),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.58,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            tooltip: l10n.actionDelete,
          ),
        ],
      ),
    );
  }
}

/// 编辑弹层：新建与编辑共用。取消返回 null。
Future<({String title, String note})?> showTplEditor(
  BuildContext context, {
  required String title,
  Item? item,
}) {
  return showTplSheet<({String title, String note})>(
    context: context,
    builder: (sheetContext) => _ItemEditorSheet(title: title, item: item),
  );
}

class _ItemEditorSheet extends StatefulWidget {
  const _ItemEditorSheet({required this.title, this.item});

  final String title;
  final Item? item;

  @override
  State<_ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<_ItemEditorSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.item?.title ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.item?.note ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l10n.errorTitleRequired);
      return;
    }
    Navigator.of(context).pop((title: title, note: _note.text.trim()));
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
          const SizedBox(height: 14),
          TplLabeledField(
            label: l10n.fieldTitle,
            controller: _title,
            hint: l10n.fieldTitleHint,
            autofocus: widget.item == null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TplLabeledField(
            label: l10n.fieldNote,
            controller: _note,
            hint: l10n.fieldNoteHint,
            minLines: 2,
            maxLines: 4,
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 10),
            TplInlineError(_error!),
          ],
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
                  onPressed: _save,
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
