import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multiai_hub/ui/theme/app_theme.dart';
import 'package:multiai_hub/ui/home/home_screen.dart';
import 'package:multiai_hub/ui/notes/notes_screen.dart';
import 'package:multiai_hub/ui/settings/settings_screen.dart';
import 'package:multiai_hub/ui/comparison/comparison_screen.dart';
import 'package:multiai_hub/ui/ask_all/ask_all_screen.dart';
import 'package:multiai_hub/ui/tabs/tabbed_browser_screen.dart';
import 'package:multiai_hub/ui/onboarding/onboarding_screen.dart';
import 'package:multiai_hub/ui/analytics/analytics_screen.dart';
import 'package:multiai_hub/viewmodel/home_viewmodel.dart';
import 'package:multiai_hub/viewmodel/notes_viewmodel.dart';
import 'package:multiai_hub/viewmodel/settings_viewmodel.dart';
import 'package:multiai_hub/services/cache/cache_service.dart';
import 'package:multiai_hub/services/notifications/notification_service.dart';
import 'package:multiai_hub/services/deep_link/deep_link_service.dart';
import 'package:multiai_hub/services/analytics/analytics_service.dart';
import 'package:multiai_hub/services/cookie/cookie_manager.dart';
import 'package:multiai_hub/services/i18n/i18n_service.dart';
import 'package:multiai_hub/ui/pipeline/pipeline_screen.dart';
import 'package:multiai_hub/ui/chat_overlay/chat_overlay.dart';
import 'package:multiai_hub/ui/components/responsive_ui.dart';
import 'package:multiai_hub/utils/network_monitor.dart';

/// App entry point - wires all features together
class MultiAIHubApp extends StatefulWidget {
  const MultiAIHubApp({super.key});

  @override
  State<MultiAIHubApp> createState() => _MultiAIHubAppState();
}

class _MultiAIHubAppState extends State<MultiAIHubApp> {
  final SettingsViewModel _settingsViewModel = SettingsViewModel();
  int _currentIndex = 0;
  bool _showOnboarding = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize all services on app startup
  Future<void> _initializeApp() async {
    // Load settings
    await _settingsViewModel.loadSettings();

    // Check if first launch (for onboarding)
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (!hasSeenOnboarding) {
      setState(() => _showOnboarding = true);
    }

    // Initialize services
    await Future.wait([
      CacheService.instance.initialize(),
      NotificationService.instance.initialize(),
      AnalyticsService.instance.ensureTable(),
      CookieManagerService.instance.initialize(),
      I18nService.instance.loadLocale(),
    ]);

    // Monitor connectivity for offline banner
    NetworkMonitor.instance.onConnectivityChanged.listen((isConnected) {
      setState(() => _isOffline = !isConnected);
    });
  }

  @override
  void dispose() {
    _settingsViewModel.dispose();
    super.dispose();
  }

  /// Complete onboarding
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    setState(() => _showOnboarding = false);
  }

  /// Screen list for bottom navigation (expanded with new features)
  late final _screens = <Widget>[
    const HomeScreen(),
    const TabbedBrowserScreen(),
    const AskAllScreen(),
    const PipelineScreen(),
    const AnalyticsScreen(),
    const NotesScreen(),
    const ComparisonScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => NotesViewModel()),
        ChangeNotifierProvider.value(value: _settingsViewModel),
      ],
      child: ListenableBuilder(
        listenable: _settingsViewModel,
        builder: (context, _) {
          return MaterialApp(
            title: 'MultiAI Hub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: _settingsViewModel.useDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: _showOnboarding
                ? OnboardingScreen(onComplete: _completeOnboarding)
                : _buildMainScaffold(),
          );
        },
      ),
    );
  }

  Widget _buildMainScaffold() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Offline banner
      body: Column(
        children: [
          // Offline indicator
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'re offline. Some features may use cached data.',
                      style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.tab_outlined),
            selectedIcon: Icon(Icons.tab),
            label: 'Tabs',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send),
            label: 'Ask All',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree),
            label: 'Pipelines',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_outlined),
            selectedIcon: Icon(Icons.compare),
            label: 'Compare',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
