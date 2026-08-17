import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/viewmodel/webview_viewmodel.dart';
import 'package:multiai_hub/viewmodel/settings_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView screen for browsing AI platforms
class WebViewScreen extends StatefulWidget {
  final AiProvider provider;

  const WebViewScreen({super.key, required this.provider});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final WebViewViewModel _viewModel = WebViewViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsViewModel>();
      _viewModel.initialize(
        widget.provider.url,
        useDesktop: settings.useDesktopMode,
      );
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.provider.name,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _viewModel.currentUrl,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            // Desktop mode toggle
            IconButton(
              icon: Icon(
                _viewModel.useDesktopMode ? Icons.monitor : Icons.phone_android,
              ),
              tooltip: _viewModel.useDesktopMode ? 'Switch to Mobile' : 'Switch to Desktop',
              onPressed: _viewModel.toggleDesktopMode,
            ),
            // Refresh
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _viewModel.reload,
            ),
            // More options
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'share', child: Text('Share URL')),
                const PopupMenuItem(value: 'open_browser', child: Text('Open in Browser')),
                const PopupMenuItem(value: 'favorite', child: Text('Toggle Favorite')),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: _viewModel.isLoading
                ? LinearProgressIndicator(
                    value: _viewModel.progress,
                    backgroundColor: Colors.transparent,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        body: _viewModel.controller != null
            ? WebViewWidget(controller: _viewModel.controller!)
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomBar(colorScheme),
      ),
    );
  }

  /// Bottom navigation bar with back/forward
  Widget _buildBottomBar(ColorScheme colorScheme) {
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
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () async {
              if (await _viewModel.canGoBack()) _viewModel.goBack();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () async {
              if (await _viewModel.canGoForward()) _viewModel.goForward();
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, size: 20),
            onPressed: () => _viewModel.loadUrl(widget.provider.url),
          ),
        ],
      ),
    );
  }

  /// Handle popup menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        // share_plus would be used here
        break;
      case 'open_browser':
        // url_launcher would be used here
        break;
      case 'favorite':
        // Toggle favorite via repository
        break;
    }
  }
}
