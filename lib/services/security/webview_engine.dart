import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/services/cookie/cookie_manager.dart';
import 'package:multiai_hub/utils/user_agent.dart';

/// Enhanced WebView engine with crash recovery, cookie persistence, and CSP
class WebViewEngine {
  final AiProvider provider;
  WebViewController? _controller;
  bool _hasCrashed = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  WebViewEngine({required this.provider});

  WebViewController? get controller => _controller;
  bool get hasCrashed => _hasCrashed;

  /// Initialize WebView with security policies and crash recovery
  WebViewController initialize({
    bool useDesktop = false,
    bool enableJavaScript = true,
    bool blockPopups = true,
    Function(bool)? onLoadingChanged,
    Function(String)? onTitleChanged,
    Function()? onCrashRecovered,
  }) {
    _controller = WebViewController()
      ..setJavaScriptMode(
        enableJavaScript ? JavaScriptMode.unrestricted : JavaScriptMode.disabled,
      )
      ..setUserAgent(UserAgent.getAgent(useDesktop: useDesktop))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {},
          onPageStarted: (url) {
            onLoadingChanged?.call(true);
          },
          onPageFinished: (url) {
            onLoadingChanged?.call(false);
            _controller?.getTitle().then((t) => onTitleChanged?.call(t ?? ''));
            // Inject CSP meta tag
            _injectContentSecurityPolicy();
          },
          onWebResourceError: (error) {
            // Crash recovery
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.connect) {
              _handleCrash(onCrashRecovered);
            }
          },
        ),
      );

    // Configure security settings
    _configureSecurity(blockPopups: blockPopups);

    // Restore cookies for this provider
    CookieManagerService.instance.restoreCookies(provider.url);

    // Load the URL
    _controller!.loadRequest(Uri.parse(provider.url));

    return _controller!;
  }

  /// Handle WebView renderer crash with automatic retry
  void _handleCrash(Function()? onCrashRecovered) {
    _hasCrashed = true;
    _retryCount++;

    if (_retryCount <= _maxRetries) {
      // Auto-retry after delay
      Future.delayed(Duration(seconds: _retryCount), () {
        _controller?.reload();
        _hasCrashed = false;
        onCrashRecovered?.call();
      });
    }
  }

  /// Configure WebView security settings
  void _configureSecurity({bool blockPopups = true}) {
    _controller?.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) {
          // Block dangerous URL schemes
          final url = request.url;
          final dangerousSchemes = ['javascript:', 'file:', 'content:', 'data:', 'intent:'];
          for (final scheme in dangerousSchemes) {
            if (url.startsWith(scheme)) {
              return NavigationDecision.prevent;
            }
          }

          // Block popups if configured
          if (blockPopups && request.isMainFrame == false) {
            return NavigationDecision.prevent;
          }

          // Enforce HTTPS
          if (url.startsWith('http://') && !url.startsWith('https://')) {
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ),
    );
  }

  /// Inject Content Security Policy meta tag
  Future<void> _injectContentSecurityPolicy() async {
    const cspScript = '''
      (function() {
        var meta = document.createElement('meta');
        meta.httpEquiv = 'Content-Security-Policy';
        meta.content = "default-src 'self' https:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; style-src 'self' 'unsafe-inline' https:; img-src 'self' https: data:; connect-src 'self' https: wss:; frame-ancestors 'none';";
        document.head.appendChild(meta);
      })();
    ''';
    try {
      await _controller?.runJavaScript(cspScript);
    } catch (_) {
      // CSP injection may fail on some pages — that's OK
    }
  }

  /// Save cookies before destroying
  Future<void> saveState() async {
    await CookieManagerService.instance.saveCookies(provider.url);
  }

  /// Destroy WebView safely
  void destroy() {
    saveState();
    _controller = null;
  }

  /// Reload with crash recovery reset
  void reload() {
    _retryCount = 0;
    _hasCrashed = false;
    _controller?.reload();
  }
}

/// Debounce utility for search and filter operations
class Debounce {
  final Duration delay;
  DateTime? _lastRun;

  Debounce({this.delay = const Duration(milliseconds: 300)});

  /// Run action if enough time has passed since last call
  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= delay) {
      _lastRun = now;
      action();
    }
  }

  /// Reset the debounce timer
  void reset() => _lastRun = null;
}

/// Rate limiter for API-like calls
class RateLimiter {
  final Duration minInterval;
  DateTime? _lastCall;

  RateLimiter({this.minInterval = const Duration(seconds: 1)});

  /// Execute action only if rate limit allows
  Future<void> execute(Future<void> Function() action) async {
    final now = DateTime.now();
    if (_lastCall != null) {
      final elapsed = now.difference(_lastCall!);
      if (elapsed < minInterval) {
        await Future.delayed(minInterval - elapsed);
      }
    }
    _lastCall = DateTime.now();
    await action();
  }
}
