import 'package:flutter/material.dart';

import '../app/logging/app_logger.dart';
import '../common_widgets.dart';
import '../l10n/app_localizations.dart';

/// 应用日志：`AppLogger` 的内存环形缓冲，最新一条在最上面。
///
/// 侧载分发的应用没有崩溃上报，出问题时这是唯一能在设备上自查的入口。
/// 只读，不写文件、不上传；日志里不允许出现用户数据（见 AGENTS.md 的 Never 规则）。
class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = AppLogger.recent.reversed.toList(growable: false);
    return Scaffold(
      body: SafeArea(
        child: TplPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TplSubHeader(
                title: l10n.logsTitle,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: entries.isEmpty
                    ? TplEmptyState(
                        icon: Icons.article_outlined,
                        title: l10n.logsEmpty,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                        itemCount: entries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) => SelectableText(
                          entries[index],
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.45,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
