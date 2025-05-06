import 'package:flutter/material.dart';
import '../models/recipe.dart';

class AppConstants {
  // App name
  static const String appName = 'Airfryer Recipes';
  
  // App version
  static const String appVersion = '1.0.0';
  
  // Recipe difficulties
  static const List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];
  
  // Cooking times (in minutes)
  static const List<int> cookingTimes = [
    10,
    15,
    20,
    30,
    45,
    60,
  ];
  
  // Temperature ranges
  static const List<double> temperatures = [
    160.0,
    180.0,
    200.0,
    220.0,
  ];
  
  // Recipe categories
  static const List<String> recipeCategories = [
    'breakfast',
    'lunch',
    'dinner',
    'snacks',
    'desserts',
    'sides',
    'mains',
    'healthy',
    'quick',
    'vegetarian',
  ];
  
  // Diet Types display names
  static final Map<DietType, String> dietTypeNames = {
    DietType.regular: 'Regular',
    DietType.vegan: 'Vegan',
    DietType.vegetarian: 'Vegetarian',
    DietType.ketogenic: 'Keto',
    DietType.glutenFree: 'Gluten-Free',
    DietType.dairyFree: 'Dairy-Free',
    DietType.lowCalorie: 'Low-Calorie',
    DietType.lowCarb: 'Low-Carb',
    DietType.highProtein: 'High-Protein',
  };
  
  // Category Icons
  static final Map<String, IconData> categoryIcons = {
    'breakfast': Icons.coffee,
    'lunch': Icons.lunch_dining,
    'dinner': Icons.dining,
    'snacks': Icons.fastfood,
    'desserts': Icons.cake,
    'sides': Icons.rice_bowl,
    'mains': Icons.restaurant,
    'healthy': Icons.favorite,
    'quick': Icons.timer,
    'vegetarian': Icons.eco,
  };
  
  // Category Colors
  static final Map<String, Color> categoryColors = {
    'breakfast': Colors.amber,
    'lunch': Colors.green,
    'dinner': Colors.indigo,
    'snacks': Colors.orange,
    'desserts': Colors.pink,
    'sides': Colors.teal,
    'mains': Colors.purple,
    'healthy': Colors.lightGreen,
    'quick': Colors.blue,
    'vegetarian': Colors.green,
  };
  
  // Languages
  static const List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'},
  ];
  
  // Default serving size
  static const int defaultServingSize = 4;
  
  // Placeholder image URL (in case recipe image is missing)
  static const String placeholderImageUrl = 'https://pixabay.com/get/ge4daf4d8b3888103941e57385b76fd08da95b412e87c7dce516ea8e019fb4b152c43c1ee6274064cbd93974c3469d445489648e2528ecc9dbc32a854680c2831_1280.jpg';
}
