import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeModeKey = 'theme_mode';
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);
    
    if (savedMode != null) {
      if (savedMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedMode == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }
  
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_themeMode == ThemeMode.dark) {
      await prefs.setString(_themeModeKey, 'dark');
    } else if (_themeMode == ThemeMode.light) {
      await prefs.setString(_themeModeKey, 'light');
    } else {
      await prefs.setString(_themeModeKey, 'system');
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveThemeMode();
    notifyListeners();
  }
  
  Future<void> toggleThemeMode() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}
