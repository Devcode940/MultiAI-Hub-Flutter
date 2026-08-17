/// User-Agent strings for WebView - mirrors Kotlin UserAgent.kt
class UserAgent {
  static const String mobile =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  static const String desktop =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  /// Get User-Agent string based on desktop mode toggle
  static String getAgent({bool useDesktop = false}) =>
      useDesktop ? desktop : mobile;
}
