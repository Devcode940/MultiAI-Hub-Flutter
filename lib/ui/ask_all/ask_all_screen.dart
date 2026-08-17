import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/viewmodel/home_viewmodel.dart';
import 'package:multiai_hub/viewmodel/ask_all_viewmodel.dart';
import 'package:multiai_hub/ui/webview/webview_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// "Ask All" screen - send the same prompt to multiple AI providers simultaneously
class AskAllScreen extends StatefulWidget {
  const AskAllScreen({super.key});

  @override
  State<AskAllScreen> createState() => _AskAllScreenState();
}

class _AskAllScreenState extends State<AskAllScreen> with TickerProviderStateMixin {
  final AskAllViewModel _askAllVM = AskAllViewModel();
  final TextEditingController _promptController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _askAllVM.dispose();
    _promptController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allProviders = context.watch<HomeViewModel>().providers;

    return ChangeNotifierProvider.value(
      value: _askAllVM,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ask All'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.edit), text: 'Compose'),
              Tab(icon: Icon(Icons.send), text: 'Results'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Compose
            _buildComposeTab(theme, colorScheme, allProviders),
            // Tab 2: Results
            _buildResultsTab(theme, colorScheme, allProviders),
          ],
        ),
      ),
    );
  }

  /// Compose tab - prompt input + provider selection
  Widget _buildComposeTab(ThemeData theme, ColorScheme colorScheme, List<AiProvider> allProviders) {
    return Column(
      children: [
        // Prompt input
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _promptController,
            decoration: InputDecoration(
              labelText: 'Your Prompt',
              hintText: 'Enter a prompt to send to all selected AIs...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.mic),
                tooltip: 'Voice Input',
                onPressed: () {
                  // Voice input integration point
                },
              ),
            ),
            maxLines: 4,
            onChanged: _askAllVM.updatePrompt,
          ),
        ),

        // Quick category select buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: AiCategory.values.where((c) => c != AiCategory.custom && c != AiCategory.favorite).map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                    label: Text('All ${cat.label}'),
                    onPressed: () => _askAllVM.selectByCategory(allProviders, cat),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Provider selection grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: allProviders.length,
            itemBuilder: (context, index) {
              final provider = allProviders[index];
              final isSelected = _askAllVM.isProviderSelected(provider);
              return Card(
                color: isSelected ? colorScheme.primaryContainer : null,
                child: InkWell(
                  onTap: () => _askAllVM.toggleProvider(provider),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.category.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          provider.name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? colorScheme.onPrimaryContainer : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, size: 16, color: colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom action bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Text(
                '${_askAllVM.selectedProviders.length} selected',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _askAllVM.canSend ? _sendToAll : null,
                icon: const Icon(Icons.send),
                label: const Text('Send to All'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Results tab - show WebView results per provider
  Widget _buildResultsTab(ThemeData theme, ColorScheme colorScheme, List<AiProvider> allProviders) {
    final selected = _askAllVM.selectedProviders;
    if (selected.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No providers selected', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Go to Compose tab to select providers', style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Provider tabs for results
        TabBar(
          isScrollable: true,
          tabs: selected.map((p) => Tab(text: '${p.category.emoji} ${p.name}')).toList(),
          tabController: TabController(length: selected.length, vsync: this),
        ),
        // WebView results (in real app, each tab would have its own WebView)
        Expanded(
          child: TabBarView(
            controller: TabController(length: selected.length, vsync: this),
            children: selected.map((provider) {
              return _WebViewWithPrompt(
                provider: provider,
                prompt: _askAllVM.prompt,
                onResult: (status) {
                  if (status) {
                    _askAllVM.markSent(provider.id!);
                  } else {
                    _askAllVM.markFailed(provider.id!, 'Injection failed');
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Send prompt to all selected providers
  void _sendToAll() {
    _askAllVM.startSending();
    _tabController.animateTo(1); // Switch to results tab
    // The WebViews will auto-inject the prompt via JavaScript
    Future.delayed(const Duration(seconds: 3), () {
      _askAllVM.finishSending();
    });
  }
}

/// WebView with auto-injected prompt
class _WebViewWithPrompt extends StatefulWidget {
  final AiProvider provider;
  final String prompt;
  final ValueChanged<bool> onResult;

  const _WebViewWithPrompt({
    required this.provider,
    required this.prompt,
    required this.onResult,
  });

  @override
  State<_WebViewWithPrompt> createState() => _WebViewWithPromptState();
}

class _WebViewWithPromptState extends State<_WebViewWithPrompt> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _isLoading = false);
            // Inject prompt after page loads
            if (widget.prompt.isNotEmpty) {
              _injectPrompt();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.provider.url));
  }

  Future<void> _injectPrompt() async {
    try {
      final script = WebViewJavaScript.injectPrompt(widget.prompt);
      final result = await _controller.runJavaScriptReturningResult(script);
      widget.onResult(result.toString() == 'true');
    } catch (e) {
      widget.onResult(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
