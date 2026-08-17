import 'package:flutter/foundation.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/utils/webview_javascript.dart';

/// ViewModel for "Ask All" mode - sends the same prompt to multiple AIs
class AskAllViewModel extends ChangeNotifier {
  String _prompt = '';
  final List<AiProvider> _selectedProviders = [];
  final Map<int, AskAllResult> _results = {};
  bool _isSending = false;

  String get prompt => _prompt;
  List<AiProvider> get selectedProviders => List.unmodifiable(_selectedProviders);
  Map<int, AskAllResult> get results => Map.unmodifiable(_results);
  bool get isSending => _isSending;
  bool get canSend => _prompt.isNotEmpty && _selectedProviders.isNotEmpty;

  /// Update the prompt text
  void updatePrompt(String value) {
    _prompt = value.trim();
    notifyListeners();
  }

  /// Toggle a provider in the selection
  void toggleProvider(AiProvider provider) {
    final index = _selectedProviders.indexWhere((p) => p.id == provider.id);
    if (index >= 0) {
      _selectedProviders.removeAt(index);
    } else {
      _selectedProviders.add(provider);
    }
    notifyListeners();
  }

  /// Check if a provider is selected
  bool isProviderSelected(AiProvider provider) {
    return _selectedProviders.any((p) => p.id == provider.id);
  }

  /// Select all providers in a category
  void selectByCategory(List<AiProvider> providers, AiCategory category) {
    final categoryProviders = providers.where((p) => p.category == category);
    for (final p in categoryProviders) {
      if (!_selectedProviders.any((sp) => sp.id == p.id)) {
        _selectedProviders.add(p);
      }
    }
    notifyListeners();
  }

  /// Clear all selections
  void clearSelection() {
    _selectedProviders.clear();
    _results.clear();
    notifyListeners();
  }

  /// Get the JavaScript injection string for a provider
  String getInjectionScript() {
    return WebViewJavaScript.injectPrompt(_prompt);
  }

  /// Mark a provider as sent
  void markSent(int providerId) {
    _results[providerId] = AskAllResult(
      providerId: providerId,
      status: AskAllStatus.sent,
      sentAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Mark a provider as failed
  void markFailed(int providerId, String error) {
    _results[providerId] = AskAllResult(
      providerId: providerId,
      status: AskAllStatus.failed,
      error: error,
      sentAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Start sending process
  void startSending() {
    _isSending = true;
    _results.clear();
    notifyListeners();
  }

  /// Finish sending process
  void finishSending() {
    _isSending = false;
    notifyListeners();
  }

  /// Reset everything
  void reset() {
    _prompt = '';
    _selectedProviders.clear();
    _results.clear();
    _isSending = false;
    notifyListeners();
  }
}

/// Result of sending prompt to a single provider
class AskAllResult {
  final int providerId;
  final AskAllStatus status;
  final String? error;
  final DateTime sentAt;

  const AskAllResult({
    required this.providerId,
    required this.status,
    this.error,
    required this.sentAt,
  });
}

enum AskAllStatus { pending, sent, failed }
