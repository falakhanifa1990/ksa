import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/recipe.dart';
import '../models/user.dart';
import '../models/grocery_item.dart';
import '../models/meal_plan.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      // For web or when database fails, return an in-memory database
      return await openDatabase(
        ':memory:',
        version: 1,
        onCreate: _createDb,
      );
    }
  }
  
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // For web, use in-memory database
      return await openDatabase(
        ':memory:',
        version: 1,
        onCreate: _createDb,
      );
    } else {
      // For mobile platforms
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'airfryer_recipes.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
      );
    }
  }
  
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        description TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        cookingSteps TEXT NOT NULL,
        cookingTimeMinutes INTEGER NOT NULL,
        servings INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        dietType TEXT NOT NULL,
        temperature REAL NOT NULL,
        nutrition TEXT,
        categories TEXT NOT NULL,
        isFeatured INTEGER NOT NULL,
        rating REAL NOT NULL,
        reviewCount INTEGER NOT NULL,
        hasVideo INTEGER NOT NULL,
        videoUrl TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE reviews(
        id TEXT PRIMARY KEY,
        recipeId TEXT NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        userPhotoUrl TEXT,
        rating REAL NOT NULL,
        comment TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE favorite_recipes(
        id TEXT PRIMARY KEY,
        FOREIGN KEY (id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE grocery_items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        recipeId TEXT,
        recipeName TEXT,
        isCompleted INTEGER NOT NULL,
        quantity REAL,
        unit TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE meal_plans(
        id TEXT PRIMARY KEY,
        date INTEGER NOT NULL,
        meals TEXT NOT NULL
      )
    ''');
  }
  
  // Recipe methods
  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    
    return List.generate(maps.length, (i) {
      final map = maps[i];
      map['ingredients'] = json.decode(map['ingredients']);
      map['cookingSteps'] = json.decode(map['cookingSteps']);
      map['categories'] = json.decode(map['categories']);
      if (map['nutrition'] != null) {
        map['nutrition'] = json.decode(map['nutrition']);
      }
      return Recipe.fromMap(map);
    });
  }
  
  Future<void> saveRecipe(Recipe recipe) async {
    final db = await database;
    final recipeMap = recipe.toMap();
    
    // Convert lists to JSON strings
    recipeMap['ingredients'] = json.encode(recipeMap['ingredients']);
    recipeMap['cookingSteps'] = json.encode(recipeMap['cookingSteps']);
    recipeMap['categories'] = json.encode(recipeMap['categories']);
    if (recipeMap['nutrition'] != null) {
      recipeMap['nutrition'] = json.encode(recipeMap['nutrition']);
    }
    
    await db.insert(
      'recipes',
      recipeMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Review methods
  Future<List<Review>> getReviews() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reviews');
    
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }
  
  Future<void> saveReview(Review review) async {
    final db = await database;
    await db.insert(
      'reviews',
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Favorite recipes methods
  Future<List<String>> getFavoriteRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorite_recipes');
    
    return List.generate(maps.length, (i) => maps[i]['id'] as String);
  }
  
  Future<void> addFavoriteRecipe(String recipeId) async {
    final db = await database;
    await db.insert(
      'favorite_recipes',
      {'id': recipeId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> removeFavoriteRecipe(String recipeId) async {
    final db = await database;
    await db.delete(
      'favorite_recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );
  }
  
  // Grocery item methods
  Future<List<GroceryItem>> getGroceryItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('grocery_items');
    
    return List.generate(maps.length, (i) => GroceryItem.fromMap(maps[i]));
  }
  
  Future<void> saveGroceryItem(GroceryItem item) async {
    final db = await database;
    await db.insert(
      'grocery_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> deleteGroceryItem(String id) async {
    final db = await database;
    await db.delete(
      'grocery_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Meal plan methods
  Future<List<MealPlan>> getMealPlans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('meal_plans');
    
    return List.generate(maps.length, (i) {
      final map = maps[i];
      map['meals'] = json.decode(map['meals']);
      return MealPlan.fromMap(map);
    });
  }
  
  Future<void> saveMealPlan(MealPlan mealPlan) async {
    final db = await database;
    final mealPlanMap = mealPlan.toMap();
    
    // Convert meals to JSON string
    mealPlanMap['meals'] = json.encode(mealPlanMap['meals']);
    
    await db.insert(
      'meal_plans',
      mealPlanMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> deleteMealPlan(String id) async {
    final db = await database;
    await db.delete(
      'meal_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // User methods
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      return User.fromJson(userData);
    }
    
    return null;
  }
  
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJson());
  }
  
  // App settings methods
  Future<AppSettings> getAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsData = prefs.getString('app_settings');
    
    if (settingsData != null) {
      return AppSettings.fromMap(json.decode(settingsData));
    }
    
    return AppSettings();
  }
  
  Future<void> saveAppSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', json.encode(settings.toMap()));
  }
}
