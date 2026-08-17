import 'package:flutter/material.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:multiai_hub/utils/user_agent.dart';

/// Model for a browser tab
class BrowserTab {
  final String id;
  final AiProvider provider;
  final WebViewController controller;
  String title;
  String url;
  bool isLoading;
  bool useDesktopMode;

  BrowserTab({
    required this.id,
    required this.provider,
    required this.controller,
    this.title = '',
    this.url = '',
    this.isLoading = true,
    this.useDesktopMode = false,
  });

  /// Initialize a new tab with a provider
  static BrowserTab create(AiProvider provider, {bool useDesktop = false}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(UserAgent.getAgent(useDesktop: useDesktop))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {},
          onPageFinished: (_) async {
            final t = await controller.getTitle();
            // Title will be updated via callback
          },
        ),
      )
      ..loadRequest(Uri.parse(provider.url));

    return BrowserTab(
      id: id,
      provider: provider,
      controller: controller,
      url: provider.url,
      useDesktopMode: useDesktop,
    );
  }
}

/// Tab manager ViewModel
class TabManager extends ChangeNotifier {
  final List<BrowserTab> _tabs = [];
  int _activeIndex = 0;
  static const int _maxTabs = 5;

  List<BrowserTab> get tabs => List.unmodifiable(_tabs);
  int get activeIndex => _activeIndex;
  int get tabCount => _tabs.length;
  bool get canAddTab => _tabs.length < _maxTabs;
  BrowserTab? get activeTab => _tabs.isNotEmpty && _activeIndex < _tabs.length ? _tabs[_activeIndex] : null;

  /// Open a new tab with a provider
  void openTab(AiProvider provider, {bool useDesktop = false}) {
    if (_tabs.length >= _maxTabs) {
      // Replace the oldest non-active tab
      _tabs.removeAt(0);
      if (_activeIndex > 0) _activeIndex--;
    }
    final tab = BrowserTab.create(provider, useDesktop: useDesktop);
    _tabs.add(tab);
    _activeIndex = _tabs.length - 1;
    notifyListeners();
  }

  /// Switch to a tab
  void switchToTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  /// Close a tab
  void closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _tabs.removeAt(index);
    if (_activeIndex >= _tabs.length) {
      _activeIndex = (_tabs.length - 1).clamp(0, _tabs.length);
    } else if (index < _activeIndex) {
      _activeIndex--;
    }
    notifyListeners();
  }

  /// Close all tabs
  void closeAllTabs() {
    _tabs.clear();
    _activeIndex = 0;
    notifyListeners();
  }

  /// Update tab title
  void updateTabTitle(int index, String title) {
    if (index < _tabs.length) {
      _tabs[index].title = title;
      notifyListeners();
    }
  }

  /// Toggle desktop mode for active tab
  void toggleDesktopMode() {
    if (activeTab != null) {
      activeTab!.useDesktopMode = !activeTab!.useDesktopMode;
      activeTab!.controller.setUserAgent(
        UserAgent.getAgent(useDesktop: activeTab!.useDesktopMode),
      );
      activeTab!.controller.reload();
      notifyListeners();
    }
  }
}
