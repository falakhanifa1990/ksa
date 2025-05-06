import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/grocery_item.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';

class MealPlanProvider with ChangeNotifier {
  List<MealPlan> _mealPlans = [];
  List<GroceryItem> _groceryItems = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  
  // Getters
  List<MealPlan> get mealPlans => _mealPlans;
  List<GroceryItem> get groceryItems => _groceryItems;
  bool get isLoading => _isLoading;
  
  Future<void> initializeMealPlans() async {
    _setLoading(true);
    
    try {
      _mealPlans = await _databaseService.getMealPlans();
      _groceryItems = await _databaseService.getGroceryItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing meal plans: $e');
      // Create empty lists if there's an error
      _mealPlans = [];
      _groceryItems = [];
    } finally {
      _setLoading(false);
    }
  }
  
  MealPlan? getMealPlanForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    
    try {
      return _mealPlans.firstWhere((plan) => 
        plan.date.year == targetDate.year && 
        plan.date.month == targetDate.month && 
        plan.date.day == targetDate.day);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> addMealToPlan(DateTime date, Recipe recipe, MealType mealType, int servings) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    
    // Check if meal plan exists for this date
    MealPlan? existingPlan = getMealPlanForDate(targetDate);
    
    final mealEntry = MealEntry(
      id: const Uuid().v4(),
      recipeId: recipe.id,
      recipeName: recipe.title,
      imageUrl: recipe.imageUrl,
      mealType: mealType,
      servings: servings,
    );
    
    if (existingPlan != null) {
      // Remove any existing meal of the same type
      final filteredMeals = existingPlan.meals
          .where((meal) => meal.mealType != mealType)
          .toList();
      
      // Add the new meal
      filteredMeals.add(mealEntry);
      
      // Update the meal plan
      final updatedPlan = existingPlan.copyWith(meals: filteredMeals);
      final index = _mealPlans.indexWhere((plan) => plan.id == existingPlan.id);
      if (index >= 0) {
        _mealPlans[index] = updatedPlan;
      }
      
      await _databaseService.saveMealPlan(updatedPlan);
    } else {
      // Create a new meal plan
      final newPlan = MealPlan(
        id: const Uuid().v4(),
        date: targetDate,
        meals: [mealEntry],
      );
      
      _mealPlans.add(newPlan);
      await _databaseService.saveMealPlan(newPlan);
    }
    
    notifyListeners();
  }
  
  Future<void> removeMealFromPlan(String mealPlanId, String mealEntryId) async {
    final index = _mealPlans.indexWhere((plan) => plan.id == mealPlanId);
    if (index >= 0) {
      final mealPlan = _mealPlans[index];
      final filteredMeals = mealPlan.meals
          .where((meal) => meal.id != mealEntryId)
          .toList();
      
      if (filteredMeals.isEmpty) {
        // If no meals left, remove the whole meal plan
        _mealPlans.removeAt(index);
        await _databaseService.deleteMealPlan(mealPlanId);
      } else {
        // Update with remaining meals
        final updatedPlan = mealPlan.copyWith(meals: filteredMeals);
        _mealPlans[index] = updatedPlan;
        await _databaseService.saveMealPlan(updatedPlan);
      }
      
      notifyListeners();
    }
  }
  
  Future<void> addGroceryItem(String name, String category, {double? quantity, String? unit, String? recipeId, String? recipeName}) async {
    final item = GroceryItem(
      id: const Uuid().v4(),
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      recipeId: recipeId,
      recipeName: recipeName,
    );
    
    _groceryItems.add(item);
    await _databaseService.saveGroceryItem(item);
    notifyListeners();
  }
  
  Future<void> toggleGroceryItemCompletion(String id) async {
    final index = _groceryItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _groceryItems[index];
      final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
      
      _groceryItems[index] = updatedItem;
      await _databaseService.saveGroceryItem(updatedItem);
      notifyListeners();
    }
  }
  
  Future<void> removeGroceryItem(String id) async {
    _groceryItems.removeWhere((item) => item.id == id);
    await _databaseService.deleteGroceryItem(id);
    notifyListeners();
  }
  
  Future<void> clearCompletedGroceryItems() async {
    final completedItems = _groceryItems.where((item) => item.isCompleted).toList();
    for (var item in completedItems) {
      await _databaseService.deleteGroceryItem(item.id);
    }
    
    _groceryItems.removeWhere((item) => item.isCompleted);
    notifyListeners();
  }
  
  Future<void> generateGroceryListFromMealPlan(List<MealPlan> mealPlans, List<Recipe> recipes) async {
    // This is a simplified implementation
    // A more sophisticated version would parse ingredients and consolidate duplicates
    
    for (var plan in mealPlans) {
      for (var meal in plan.meals) {
        final recipe = recipes.firstWhere(
          (recipe) => recipe.id == meal.recipeId,
          orElse: () => throw Exception('Recipe not found'),
        );
        
        // Add each ingredient as a grocery item
        for (var ingredient in recipe.ingredients) {
          // This is a simple approach - in a real app, you'd parse the ingredient
          // string to extract quantity, unit, and name
          await addGroceryItem(
            ingredient, 
            GroceryCategory.other.displayName,
            recipeId: recipe.id,
            recipeName: recipe.title,
          );
        }
      }
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
