import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/viewmodel/tabs/tab_manager.dart';
import 'package:multiai_hub/viewmodel/home_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Tabbed browser screen - multiple AI WebViews with tab bar
class TabbedBrowserScreen extends StatefulWidget {
  const TabbedBrowserScreen({super.key});

  @override
  State<TabbedBrowserScreen> createState() => _TabbedBrowserScreenState();
}

class _TabbedBrowserScreenState extends State<TabbedBrowserScreen> {
  final TabManager _tabManager = TabManager();

  @override
  void dispose() {
    _tabManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChangeNotifierProvider.value(
      value: _tabManager,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Multi-AI Tabs'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Tab',
              onPressed: () => _showProviderPicker(context),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close All',
              onPressed: () => _tabManager.closeAllTabs(),
            ),
          ],
        ),
        body: _tabManager.tabs.isEmpty
            ? _buildEmptyState(theme, colorScheme)
            : Column(
                children: [
                  // Tab bar
                  _buildTabBar(theme, colorScheme),
                  // Active WebView
                  Expanded(
                    child: IndexedStack(
                      index: _tabManager.activeIndex,
                      children: _tabManager.tabs.map((tab) {
                        return WebViewWidget(controller: tab.controller);
                      }).toList(),
                    ),
                  ),
                  // Bottom navigation for active tab
                  _buildBottomNav(colorScheme),
                ],
              ),
      ),
    );
  }

  /// Empty state when no tabs are open
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tab_outlined, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('No tabs open', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Tap + to open an AI provider', style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showProviderPicker(context),
            icon: const Icon(Icons.add),
            label: const Text('Open AI Provider'),
          ),
        ],
      ),
    );
  }

  /// Horizontal scrollable tab bar
  Widget _buildTabBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _tabManager.tabCount,
        itemBuilder: (context, index) {
          final tab = _tabManager.tabs[index];
          final isActive = index == _tabManager.activeIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Material(
              color: isActive ? colorScheme.primaryContainer : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => _tabManager.switchToTab(index),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab.provider.category.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab.provider.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _tabManager.closeTab(index),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Bottom navigation bar for active tab
  Widget _buildBottomNav(ColorScheme colorScheme) {
    final tab = _tabManager.activeTab;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => tab?.controller.goBack(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: () => tab?.controller.goForward(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () => tab?.controller.reload(),
          ),
          IconButton(
            icon: Icon(
              tab?.useDesktopMode ?? false ? Icons.monitor : Icons.phone_android,
              size: 18,
            ),
            onPressed: _tabManager.toggleDesktopMode,
          ),
          IconButton(
            icon: const Icon(Icons.home, size: 18),
            onPressed: () {
              if (tab != null) {
                tab.controller.loadRequest(Uri.parse(tab.provider.url));
              }
            },
          ),
        ],
      ),
    );
  }

  /// Show provider picker to open in a new tab
  void _showProviderPicker(BuildContext context) {
    final providers = context.read<HomeViewModel>().providers;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Open in New Tab', style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return Card(
                    child: InkWell(
                      onTap: () {
                        _tabManager.openTab(provider);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(provider.category.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              provider.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
