import 'package:flutter/material.dart';
import 'package:multiai_hub/data/models/models.dart';

/// Responsive grid helper - adjusts columns based on screen width
class ResponsiveGrid {
  /// Get optimal cross-axis count based on screen width
  static int getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 2;       // Small phone
    if (width < 600) return 3;       // Phone
    if (width < 900) return 4;       // Large phone / small tablet
    if (width < 1200) return 5;      // Tablet
    return 6;                         // Desktop / large tablet
  }

  /// Get card aspect ratio based on columns
  static double getAspectRatio(int columns) {
    switch (columns) {
      case 2: return 0.85;
      case 3: return 0.78;
      case 4: return 0.75;
      case 5: return 0.72;
      default: return 0.70;
    }
  }

  /// Get padding based on screen size
  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return const EdgeInsets.all(8);
    if (width < 900) return const EdgeInsets.all(12);
    return const EdgeInsets.all(16);
  }

  /// Should use navigation rail (tablet/desktop) vs bottom bar (phone)
  static bool shouldUseNavigationRail(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }
}

/// Provider logo service - maps provider names to their favicon URLs
class ProviderLogos {
  static const Map<String, String> _logoUrls = {
    'ChatGPT': 'https://cdn.oaistatic.com/_next/static/media/logo.7c55e626.svg',
    'Claude': 'https://claude.ai/images/claude_app_icon.png',
    'Gemini': 'https://www.gstatic.com/lamda/images/gemini_sparkle_v002_d4735304ff6bf2e0ce5a3993.svg',
    'Grok': 'https://grok.x.ai/favicon.ico',
    'DeepSeek': 'https://chat.deepseek.com/favicon.ico',
    'Perplexity': 'https://www.perplexity.ai/favicon.ico',
    'HuggingChat': 'https://huggingface.co/front/assets/huggingface_logo.svg',
  };

  /// Get logo URL for a provider
  static String? getLogoUrl(String providerName) => _logoUrls[providerName];

  /// Get favicon URL (works for any provider)
  static String getFaviconUrl(String providerUrl) {
    final uri = Uri.parse(providerUrl);
    return '${uri.scheme}://${uri.host}/favicon.ico';
  }

  /// Check if we have a high-quality logo for this provider
  static bool hasHqLogo(String providerName) => _logoUrls.containsKey(providerName);
}

/// Hero animation wrapper for provider cards
class ProviderHero extends StatelessWidget {
  final AiProvider provider;
  final Widget child;

  const ProviderHero({
    super.key,
    required this.provider,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'provider_${provider.id}_${provider.name}',
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// Adaptive navigation - uses NavigationRail on wide screens, BottomNav on narrow
class AdaptiveNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget body;

  const AdaptiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveGrid.shouldUseNavigationRail(context)) {
      return _buildNavigationRail(context);
    }
    return _buildBottomNavigation(context);
  }

  Widget _buildNavigationRail(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('MultiAI', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            )),
          ),
          destinations: destinations.map((d) {
            return NavigationRailDestination(
              icon: d.icon,
              selectedIcon: d.selectedIcon,
              label: Text(d.label),
            );
          }).toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: body),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}

/// Pull-to-refresh WebView wrapper
class RefreshableWebView extends StatefulWidget {
  final Widget child;
  final VoidCallback onRefresh;

  const RefreshableWebView({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<RefreshableWebView> createState() => _RefreshableWebViewState();
}

class _RefreshableWebViewState extends State<RefreshableWebView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
        // Small delay to show the indicator
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: widget.child,
    );
  }
}
