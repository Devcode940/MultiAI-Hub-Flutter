import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/viewmodel/home_viewmodel.dart';
import 'package:multiai_hub/viewmodel/webview_viewmodel.dart';

/// Comparison screen - side-by-side AI comparison
class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  AiProvider? _leftProvider;
  AiProvider? _rightProvider;
  final _leftWebView = WebViewViewModel();
  final _rightWebView = WebViewViewModel();

  @override
  void dispose() {
    _leftWebView.dispose();
    _rightWebView.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final providers = context.watch<HomeViewModel>().providers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Swap sides',
            onPressed: _swapProviders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Provider selectors
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: _buildProviderDropdown('Left', _leftProvider, providers, (p) {
                  setState(() => _leftProvider = p);
                  if (p != null) _leftWebView.initialize(p.url);
                })),
                const SizedBox(width: 8),
                Expanded(child: _buildProviderDropdown('Right', _rightProvider, providers, (p) {
                  setState(() => _rightProvider = p);
                  if (p != null) _rightWebView.initialize(p.url);
                })),
              ],
            ),
          ),

          // Side-by-side WebViews
          Expanded(
            child: _leftProvider == null || _rightProvider == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.compare, size: 64, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('Select two AI providers to compare', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Choose from the dropdowns above', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: theme.colorScheme.primaryContainer,
                              width: double.infinity,
                              child: Text(
                                _leftProvider!.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _leftWebView.controller != null
                                  ? WebViewWidget(controller: _leftWebView.controller!)
                                  : const Center(child: CircularProgressIndicator()),
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: theme.colorScheme.tertiaryContainer,
                              width: double.infinity,
                              child: Text(
                                _rightProvider!.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _rightWebView.controller != null
                                  ? WebViewWidget(controller: _rightWebView.controller!)
                                  : const Center(child: CircularProgressIndicator()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderDropdown(
    String label,
    AiProvider? selected,
    List<AiProvider> providers,
    ValueChanged<AiProvider?> onChanged,
  ) {
    return DropdownButtonFormField<AiProvider?>(
      value: selected,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Select...')),
        ...providers.map((p) => DropdownMenuItem(
              value: p,
              child: Text('${p.category.emoji} ${p.name}', overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: onChanged,
    );
  }

  void _swapProviders() {
    setState(() {
      final temp = _leftProvider;
      _leftProvider = _rightProvider;
      _rightProvider = temp;
    });
    if (_leftProvider != null) _leftWebView.initialize(_leftProvider!.url);
    if (_rightProvider != null) _rightWebView.initialize(_rightProvider!.url);
  }
}
