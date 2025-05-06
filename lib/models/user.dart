import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> favoriteRecipeIds;
  final List<String> dietaryPreferences;
  final Map<String, dynamic> settings;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.favoriteRecipeIds = const [],
    this.dietaryPreferences = const [],
    this.settings = const {},
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    List<String>? favoriteRecipeIds,
    List<String>? dietaryPreferences,
    Map<String, dynamic>? settings,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteRecipeIds: favoriteRecipeIds ?? this.favoriteRecipeIds,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'favoriteRecipeIds': favoriteRecipeIds,
      'dietaryPreferences': dietaryPreferences,
      'settings': settings,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      favoriteRecipeIds: List<String>.from(map['favoriteRecipeIds'] ?? []),
      dietaryPreferences: List<String>.from(map['dietaryPreferences'] ?? []),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  // Helper methods
  bool hasRecipeInFavorites(String recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }

  bool isDarkModeEnabled() {
    return settings['darkMode'] == true;
  }

  String getLanguageCode() {
    return settings['languageCode'] ?? 'en';
  }
}

class AppSettings {
  final bool isDarkMode;
  final String languageCode;
  final bool notificationsEnabled;
  final int servingSizeDefault;
  final bool offlineDownloadsEnabled;
  
  AppSettings({
    this.isDarkMode = false,
    this.languageCode = 'en',
    this.notificationsEnabled = true,
    this.servingSizeDefault = 4,
    this.offlineDownloadsEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'languageCode': languageCode,
      'notificationsEnabled': notificationsEnabled,
      'servingSizeDefault': servingSizeDefault,
      'offlineDownloadsEnabled': offlineDownloadsEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      isDarkMode: map['isDarkMode'] ?? false,
      languageCode: map['languageCode'] ?? 'en',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      servingSizeDefault: map['servingSizeDefault'] ?? 4,
      offlineDownloadsEnabled: map['offlineDownloadsEnabled'] ?? false,
    );
  }

  AppSettings copyWith({
    bool? isDarkMode,
    String? languageCode,
    bool? notificationsEnabled,
    int? servingSizeDefault,
    bool? offlineDownloadsEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      servingSizeDefault: servingSizeDefault ?? this.servingSizeDefault,
      offlineDownloadsEnabled: offlineDownloadsEnabled ?? this.offlineDownloadsEnabled,
    );
  }
}
