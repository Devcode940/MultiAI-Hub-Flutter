import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings ViewModel - manages app preferences
class SettingsViewModel extends ChangeNotifier {
  bool _useDesktopMode = false;
  bool _useDarkMode = true;
  bool _blockPopups = true;
  bool _enableJavaScript = true;
  bool _isLoaded = false;

  bool get useDesktopMode => _useDesktopMode;
  bool get useDarkMode => _useDarkMode;
  bool get blockPopups => _blockPopups;
  bool get enableJavaScript => _enableJavaScript;

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _useDesktopMode = prefs.getBool('useDesktopMode') ?? false;
    _useDarkMode = prefs.getBool('useDarkMode') ?? true;
    _blockPopups = prefs.getBool('blockPopups') ?? true;
    _enableJavaScript = prefs.getBool('enableJavaScript') ?? true;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
  }

  void setDesktopMode(bool value) {
    _useDesktopMode = value;
    _save('useDesktopMode', value);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _useDarkMode = value;
    _save('useDarkMode', value);
    notifyListeners();
  }

  void setBlockPopups(bool value) {
    _blockPopups = value;
    _save('blockPopups', value);
    notifyListeners();
  }

  void setEnableJavaScript(bool value) {
    _enableJavaScript = value;
    _save('enableJavaScript', value);
    notifyListeners();
  }
}
