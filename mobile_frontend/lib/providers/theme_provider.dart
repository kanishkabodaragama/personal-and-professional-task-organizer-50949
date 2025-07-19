import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  ThemeProvider(bool initialDarkMode) {
    _isDarkMode = initialDarkMode;
  }
  
  bool get isDarkMode => _isDarkMode;
  
  // PUBLIC_INTERFACE
  /// Toggles between light and dark theme modes
  /// Persists the choice in SharedPreferences
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    // Persist theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
  
  // PUBLIC_INTERFACE
  /// Sets the theme mode explicitly
  /// @param isDark - true for dark mode, false for light mode
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
      
      // Persist theme preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    }
  }
}
