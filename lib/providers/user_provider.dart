import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  AppSettings _appSettings = AppSettings();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  
  // Getters
  User? get currentUser => _currentUser;
  AppSettings get appSettings => _appSettings;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  
  Future<void> initializeUser() async {
    _setLoading(true);
    
    try {
      // Load settings first (these can exist without a user)
      _appSettings = await _databaseService.getAppSettings();
      
      // Try to load existing user
      final user = await _databaseService.getUser();
      if (user != null) {
        _currentUser = user;
      } else {
        // Create a mock user if none exists
        _createMockUser();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing user: $e');
      _createMockUser();
    } finally {
      _setLoading(false);
    }
  }
  
  void _createMockUser() {
    _currentUser = User(
      id: const Uuid().v4(),
      name: 'Guest User',
      email: 'guest@example.com',
      favoriteRecipeIds: [],
      dietaryPreferences: [],
      settings: _appSettings.toMap(),
    );
    
    // Save the mock user
    _databaseService.saveUser(_currentUser!);
  }
  
  Future<void> updateUser({
    String? name,
    String? email,
    String? photoUrl,
    List<String>? dietaryPreferences,
  }) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      photoUrl: photoUrl,
      dietaryPreferences: dietaryPreferences,
    );
    
    await _databaseService.saveUser(_currentUser!);
    notifyListeners();
  }
  
  Future<void> updateSettings(AppSettings newSettings) async {
    _appSettings = newSettings;
    
    // Update user settings as well if user exists
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        settings: newSettings.toMap(),
      );
      await _databaseService.saveUser(_currentUser!);
    }
    
    await _databaseService.saveAppSettings(newSettings);
    notifyListeners();
  }
  
  Future<void> toggleDarkMode() async {
    final newSettings = _appSettings.copyWith(
      isDarkMode: !_appSettings.isDarkMode,
    );
    
    await updateSettings(newSettings);
  }
  
  Future<void> changeLanguage(String languageCode) async {
    final newSettings = _appSettings.copyWith(
      languageCode: languageCode,
    );
    
    await updateSettings(newSettings);
  }
  
  Future<void> toggleNotifications() async {
    final newSettings = _appSettings.copyWith(
      notificationsEnabled: !_appSettings.notificationsEnabled,
    );
    
    await updateSettings(newSettings);
  }
  
  Future<void> toggleOfflineDownloads() async {
    final newSettings = _appSettings.copyWith(
      offlineDownloadsEnabled: !_appSettings.offlineDownloadsEnabled,
    );
    
    await updateSettings(newSettings);
  }
  
  Future<void> updateDefaultServingSize(int servingSize) async {
    final newSettings = _appSettings.copyWith(
      servingSizeDefault: servingSize,
    );
    
    await updateSettings(newSettings);
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
