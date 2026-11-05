import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'home_page.dart';
import 'settings_page.dart';

/// 主界面外壳：底部两个标签 + IndexedStack 保持各自滚动位置。
///
/// 页面各自带 Scaffold，外壳只负责导航栏；新增标签时在这里加一项即可。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const <Widget>[HomePage(), SettingsPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.inbox_outlined),
            selectedIcon: const Icon(Icons.inbox_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
