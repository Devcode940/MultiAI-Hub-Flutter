import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:multiai_hub/utils/user_agent.dart';

/// WebView state and controller management
class WebViewViewModel extends ChangeNotifier {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _useDesktopMode = false;
  String _currentUrl = '';
  String _title = '';
  double _progress = 0;

  bool get isLoading => _isLoading;
  bool get useDesktopMode => _useDesktopMode;
  String get currentUrl => _currentUrl;
  String get title => _title;
  double get progress => _progress;
  WebViewController? get controller => _controller;

  /// Initialize WebView controller for a given URL
  void initialize(String url, {bool useDesktop = false}) {
    _currentUrl = url;
    _useDesktopMode = useDesktop;
    _isLoading = true;
    _progress = 0;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            _progress = p / 100;
            notifyListeners();
          },
          onPageStarted: (url) {
            _isLoading = true;
            notifyListeners();
          },
          onPageFinished: (url) {
            _isLoading = false;
            _controller?.getTitle().then((t) {
              _title = t ?? '';
              notifyListeners();
            });
            notifyListeners();
          },
          onWebResourceError: (error) {
            _isLoading = false;
            notifyListeners();
          },
        ),
      )
      ..setUserAgent(UserAgent.getAgent(useDesktop: _useDesktopMode))
      ..loadRequest(Uri.parse(url));

    notifyListeners();
  }

  /// Toggle between mobile and desktop mode
  void toggleDesktopMode() {
    _useDesktopMode = !_useDesktopMode;
    _controller?.setUserAgent(UserAgent.getAgent(useDesktop: _useDesktopMode));
    _controller?.reload();
    notifyListeners();
  }

  /// Navigate back
  Future<bool> canGoBack() async => _controller?.canGoBack() ?? false;
  Future<void> goBack() async => _controller?.goBack();

  /// Navigate forward
  Future<bool> canGoForward() async => _controller?.canGoForward() ?? false;
  Future<void> goForward() async => _controller?.goForward();

  /// Reload current page
  void reload() => _controller?.reload();

  /// Load a new URL
  void loadUrl(String url) {
    _currentUrl = url;
    _controller?.loadRequest(Uri.parse(url));
    notifyListeners();
  }
}
