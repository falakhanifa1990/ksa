import 'package:flutter/material.dart';

class AppTheme {
  // App Colors
  static const Color primaryColor = Color(0xFF6E9C56);
  static const Color secondaryColor = Color(0xFFF5C35F);
  static const Color accentColor = Color(0xFFE17654);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFF8F7F2);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Color(0xFF333333);
  static const Color lightSubtextColor = Color(0xFF6B6B6B);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkCardColor = Color(0xFF2C2C2C);
  static const Color darkTextColor = Color(0xFFF8F7F2);
  static const Color darkSubtextColor = Color(0xFFBBBBBB);

  // Other colors
  static const Color errorColor = Color(0xFFE84C3D);
  static const Color successColor = Color(0xFF58C373);
  static const Color warningColor = Color(0xFFF5C35F);

  // Typography
  static const fontFamily = 'Roboto'; // Default Flutter font

  // Card styling
  static final cardRadius = BorderRadius.circular(16.0);
  static final cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      iconTheme: IconThemeData(color: lightTextColor),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: lightTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: lightTextColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: lightSubtextColor,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: lightCardColor,
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCardColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      iconTheme: IconThemeData(color: darkTextColor),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: darkTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: darkTextColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: darkSubtextColor,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: darkCardColor,
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightCardColor,
      contentTextStyle: const TextStyle(color: Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
