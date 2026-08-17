import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/viewmodel/home_viewmodel.dart';
import 'package:multiai_hub/ui/components/components.dart';
import 'package:multiai_hub/ui/webview/webview_screen.dart';

/// Home screen - displays AI provider grid with category filters
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RefreshIndicatorState {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadProviders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MultiAI Hub'),
        actions: [
          // Search toggle
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          // Add custom provider
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProviderDialog(context),
          ),
        ],
        bottom: vm.searchQuery.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Searching: "${vm.searchQuery}"',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => context.read<HomeViewModel>().updateSearchQuery(''),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // Category filter chips
          _buildCategoryChips(vm),

          // Provider grid
          Expanded(
            child: vm.isLoading
                ? _buildLoadingGrid()
                : vm.error != null
                    ? _buildError(vm.error!, vm)
                    : vm.providers.isEmpty
                        ? _buildEmptyState()
                        : _buildProviderGrid(vm),
          ),
        ],
      ),
    );
  }

  /// Horizontal scrollable category chips
  Widget _buildCategoryChips(HomeViewModel vm) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          CategoryChip(
            category: AiCategory.chat, // We'll use a special case
            isSelected: vm.selectedCategory == null,
            onTap: () => context.read<HomeViewModel>().selectCategory(null),
          ),
          // Category chips
          ...AiCategory.values.map((cat) {
            // Override the "All" chip label
            if (cat == AiCategory.chat && vm.selectedCategory == null) {
              // skip, handled above
            }
            return CategoryChip(
              category: cat,
              isSelected: vm.selectedCategory == cat,
              onTap: () => context.read<HomeViewModel>().selectCategory(cat),
            );
          }),
        ],
      ),
    );
  }

  /// Provider grid with staggered layout
  Widget _buildProviderGrid(HomeViewModel vm) {
    return RefreshIndicator(
      onRefresh: () => vm.loadProviders(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: vm.providers.length,
        itemBuilder: (context, index) {
          final provider = vm.providers[index];
          return AiCard(
            provider: provider,
            onTap: () => _openProvider(context, provider),
            onFavoriteToggle: () => vm.toggleFavorite(provider),
          );
        },
      ),
    );
  }

  /// Loading state
  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => const Card(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// Error state
  Widget _buildError(String error, HomeViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text('Something went wrong', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => vm.loadProviders(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('No AI providers found', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Try a different search or category', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  /// Open AI provider in WebView
  void _openProvider(BuildContext context, AiProvider provider) {
    context.read<HomeViewModel>().recordLastUsed(provider);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebViewScreen(provider: provider),
      ),
    );
  }

  /// Show search dialog
  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _AiSearchDelegate(context.read<HomeViewModel>()),
    );
  }

  /// Show add custom provider dialog
  void _showAddProviderDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., My Custom AI',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'e.g., example.com',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty) {
                context.read<HomeViewModel>().addCustomProvider(
                      nameCtrl.text,
                      urlCtrl.text,
                      description: descCtrl.text,
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Search delegate for AI providers
class _AiSearchDelegate extends SearchDelegate<String> {
  final HomeViewModel _viewModel;

  _AiSearchDelegate(this._viewModel);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _viewModel.updateSearchQuery('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _viewModel.updateSearchQuery(query);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: _viewModel.providers.length,
          itemBuilder: (context, index) {
            final provider = _viewModel.providers[index];
            return ListTile(
              leading: Text(provider.category.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(provider.name),
              subtitle: Text(provider.description, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                _viewModel.recordLastUsed(provider);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(provider: provider),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);
}
