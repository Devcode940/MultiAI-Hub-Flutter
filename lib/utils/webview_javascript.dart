/// WebView JavaScript injection utilities - mirrors Kotlin WebViewJavaScript.kt
class WebViewJavaScript {
  /// Inject a prompt into the page's input field
  static String injectPrompt(String prompt) {
    final escaped = prompt
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
    return '''
      (function() {
        var selectors = [
          'textarea', 'input[type="text"]', '[contenteditable="true"]',
          '#prompt-textarea', '#chat-input', '.ProseMirror',
          '[data-testid="chat-input"]', '.ql-editor'
        ];
        for (var i = 0; i < selectors.length; i++) {
          var el = document.querySelector(selectors[i]);
          if (el) {
            el.focus();
            el.textContent = '$escaped';
            el.value = '$escaped';
            el.dispatchEvent(new Event('input', {bubbles: true}));
            el.dispatchEvent(new Event('change', {bubbles: true}));
            return true;
          }
        }
        return false;
      })();
    ''';
  }

  /// Clear all cookies (call from native side)
  static const String clearCookies = 'document.cookie.split(";").forEach(function(c){document.cookie=c.replace(/^ +/,"").replace(/=.*/,"=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/")})';
}
