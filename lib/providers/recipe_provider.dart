import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/sample_recipes.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Review> _reviews = [];
  List<String> _favoriteRecipes = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  
  // Getters
  List<Recipe> get recipes => _recipes;
  List<Review> get reviews => _reviews;
  List<String> get favoriteRecipes => _favoriteRecipes;
  bool get isLoading => _isLoading;
  
  List<Recipe> get featuredRecipes => _recipes
      .where((recipe) => recipe.isFeatured)
      .toList();
      
  List<Recipe> get popularRecipes => _recipes
      .where((recipe) => recipe.rating >= 4.0 && recipe.reviewCount > 0)
      .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
      
  List<Recipe> get quickAndEasyRecipes => _recipes
      .where((recipe) => recipe.cookingTimeMinutes <= 20)
      .toList()
      ..sort((a, b) => a.cookingTimeMinutes.compareTo(b.cookingTimeMinutes));
      
  List<Recipe> get healthyRecipes => _recipes
      .where((recipe) => 
          recipe.dietType == DietType.lowCalorie || 
          recipe.dietType == DietType.vegan || 
          recipe.categories.contains('healthy'))
      .toList();
  
  Future<void> initializeRecipes() async {
    _setLoading(true);
    
    try {
      // Try to load from local database
      final recipes = await _databaseService.getRecipes();
      
      if (recipes.isEmpty) {
        // If no recipes in database, use sample data
        _recipes = SampleRecipes.getRecipes();
        // Save sample recipes to database
        for (var recipe in _recipes) {
          await _databaseService.saveRecipe(recipe);
        }
      } else {
        _recipes = recipes;
      }
      
      // Load reviews
      _reviews = await _databaseService.getReviews();
      
      // Load favorite recipes
      _favoriteRecipes = await _databaseService.getFavoriteRecipes();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing recipes: $e');
      // Fallback to sample data if there's an error
      _recipes = SampleRecipes.getRecipes();
    } finally {
      _setLoading(false);
    }
  }
  
  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Recipe> getRecipesByCategory(String category) {
    return _recipes.where((recipe) => recipe.categories.contains(category)).toList();
  }
  
  List<Recipe> getRecipesByDietType(DietType dietType) {
    return _recipes.where((recipe) => recipe.dietType == dietType).toList();
  }
  
  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) {
      return _recipes;
    }
    
    query = query.toLowerCase();
    
    return _recipes.where((recipe) {
      final titleMatch = recipe.title.toLowerCase().contains(query);
      final descriptionMatch = recipe.description.toLowerCase().contains(query);
      final ingredientMatch = recipe.ingredients.any((ingredient) => 
        ingredient.toLowerCase().contains(query));
        
      return titleMatch || descriptionMatch || ingredientMatch;
    }).toList();
  }
  
  Future<void> toggleFavorite(String recipeId) async {
    if (_favoriteRecipes.contains(recipeId)) {
      _favoriteRecipes.remove(recipeId);
      await _databaseService.removeFavoriteRecipe(recipeId);
    } else {
      _favoriteRecipes.add(recipeId);
      await _databaseService.addFavoriteRecipe(recipeId);
    }
    notifyListeners();
  }
  
  bool isFavorite(String recipeId) {
    return _favoriteRecipes.contains(recipeId);
  }
  
  List<Recipe> getFavoriteRecipesList() {
    return _recipes.where((recipe) => _favoriteRecipes.contains(recipe.id)).toList();
  }
  
  Future<void> addReview(String recipeId, String userId, String userName, double rating, String comment) async {
    final review = Review(
      id: const Uuid().v4(),
      recipeId: recipeId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    
    _reviews.add(review);
    await _databaseService.saveReview(review);
    
    // Update recipe rating
    final recipeReviews = _reviews.where((r) => r.recipeId == recipeId).toList();
    final totalRating = recipeReviews.fold(0.0, (sum, r) => sum + r.rating);
    final newRating = totalRating / recipeReviews.length;
    
    // Find and update recipe
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index >= 0) {
      _recipes[index] = _recipes[index].copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewCount: recipeReviews.length,
      );
      
      await _databaseService.saveRecipe(_recipes[index]);
    }
    
    notifyListeners();
  }
  
  List<Review> getReviewsForRecipe(String recipeId) {
    return _reviews
        .where((review) => review.recipeId == recipeId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  // Filter recipes by multiple criteria
  List<Recipe> filterRecipes({
    int? maxCookingTime,
    DietType? dietType,
    String? difficulty,
    List<String>? categories,
  }) {
    return _recipes.where((recipe) {
      bool timeMatch = maxCookingTime == null || recipe.cookingTimeMinutes <= maxCookingTime;
      bool dietMatch = dietType == null || recipe.dietType == dietType;
      bool difficultyMatch = difficulty == null || recipe.difficulty == difficulty;
      bool categoriesMatch = categories == null || categories.isEmpty || 
          categories.any((category) => recipe.categories.contains(category));
          
      return timeMatch && dietMatch && difficultyMatch && categoriesMatch;
    }).toList();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
