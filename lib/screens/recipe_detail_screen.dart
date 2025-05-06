import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/recipe.dart';
import '../models/meal_plan.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/recipe_provider.dart';
import '../screens/cooking_mode_screen.dart';
import '../widgets/timer_widget.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  
  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _servings = 4;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final recipe = recipeProvider.getRecipeById(widget.recipeId);
        
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe Not Found')),
            body: const Center(child: Text('The recipe you are looking for does not exist.')),
          );
        }
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, recipe, recipeProvider),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(recipe),
                    _buildTabBar(),
                    _buildTabBarView(recipe),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, recipe),
        );
      },
    );
  }
  
  Widget _buildSliverAppBar(BuildContext context, Recipe recipe, RecipeProvider recipeProvider) {
    final isFavorite = recipeProvider.isFavorite(recipe.id);
    
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'recipe_${recipe.id}',
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.darken,
            child: Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.3),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              recipeProvider.toggleFavorite(recipe.id);
            },
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share recipe functionality would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing is not implemented in this demo'))
              );
            },
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
  
  Widget _buildInfoSection(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            recipe.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                Icons.access_time,
                '${recipe.cookingTimeMinutes} min',
                'Cook Time',
              ),
              _buildInfoItem(
                Icons.thermostat,
                '${recipe.temperature.toInt()}°',
                'Temperature',
              ),
              _buildInfoItem(
                Icons.restaurant,
                recipe.difficulty,
                'Difficulty',
              ),
              _buildInfoItem(
                Icons.people,
                '$_servings',
                'Servings',
                showStepper: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              RatingBar.builder(
                initialRating: recipe.rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                ignoreGestures: true,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: AppTheme.secondaryColor,
                ),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(width: 8),
              Text(
                '(${recipe.reviewCount} ${recipe.reviewCount == 1 ? 'review' : 'reviews'})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(recipe.dietType.toString().split('.').last),
              ...recipe.categories.map((category) => _buildChip(category)).toList(),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String value, String label, {bool showStepper = false}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            if (!showStepper)
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            if (showStepper)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_servings > 1) {
                        setState(() {
                          _servings--;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.remove, size: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _servings++;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Ingredients'),
          Tab(text: 'Instructions'),
          Tab(text: 'Reviews'),
        ],
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
      ),
    );
  }
  
  Widget _buildTabBarView(Recipe recipe) {
    return SizedBox(
      height: 500, // Fixed height for the tab content
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildIngredientsTab(recipe),
          _buildInstructionsTab(recipe),
          _buildReviewsTab(recipe),
        ],
      ),
    );
  }
  
  Widget _buildIngredientsTab(Recipe recipe) {
    List<String> scaledIngredients = recipe.ingredients.map((ingredient) {
      // This is a simplified scaling approach. In a real app, you would
      // parse the ingredient string and scale the quantity properly.
      final originalServings = recipe.servings;
      final scaleFactor = _servings / originalServings;
      
      // Simple scaling by looking for numbers at the beginning of the string
      final regex = RegExp(r'^(\d+(\.\d+)?)');
      final match = regex.firstMatch(ingredient);
      
      if (match != null) {
        final quantity = double.parse(match.group(1)!);
        final scaledQuantity = (quantity * scaleFactor).toStringAsFixed(1);
        // Remove trailing zeros after decimal point
        final cleanQuantity = scaledQuantity.endsWith('.0') 
            ? scaledQuantity.substring(0, scaledQuantity.length - 2)
            : scaledQuantity;
        
        return ingredient.replaceFirst(match.group(0)!, cleanQuantity);
      }
      
      return ingredient;
    }).toList();
  
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients for $_servings ${_servings == 1 ? 'serving' : 'servings'}',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: scaledIngredients.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fiber_manual_record, size: 12, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          scaledIngredients[index],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionsTab(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step-by-Step Instructions',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: recipe.cookingSteps.length,
              itemBuilder: (context, index) {
                final step = recipe.cookingSteps[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          '${step.stepNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.instruction,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (step.timerMinutes != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TimerWidget(minutes: step.timerMinutes!),
                              ),
                            if (step.image != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    step.image!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewsTab(Recipe recipe) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final reviews = recipeProvider.getReviewsForRecipe(recipe.id);
        
        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No reviews yet',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to review this recipe',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showReviewDialog(context, recipe);
                  },
                  child: const Text('Write a Review'),
                ),
              ],
            ),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviews (${reviews.length})',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Review'),
                    onPressed: () {
                      _showReviewDialog(context, recipe);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor,
                                      child: Text(
                                        review.userName.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      review.userName,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  _formatDate(review.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: review.rating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 16,
                                  ignoreGestures: true,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: AppTheme.secondaryColor,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.comment,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
  
  void _showReviewDialog(BuildContext context, Recipe recipe) {
    double rating = 5.0;
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Write a Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How would you rate this recipe?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: AppTheme.secondaryColor,
                  ),
                  onRatingUpdate: (newRating) {
                    rating = newRating;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    hintText: 'Share your experience with this recipe',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  context.read<RecipeProvider>().addReview(
                    recipe.id,
                    'user123',  // In a real app, this would be the current user's ID
                    'User',    // In a real app, this would be the current user's name
                    rating,
                    commentController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBottomBar(BuildContext context, Recipe recipe) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CookingModeScreen(recipe: recipe, servings: _servings),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start Cooking'),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {
                _showAddToMealPlanDialog(context, recipe);
              },
              icon: const Icon(Icons.calendar_today),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddToMealPlanDialog(BuildContext context, Recipe recipe) {
    MealType selectedMealType = MealType.dinner;
    DateTime selectedDate = DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Meal Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a date',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (date) {
                      selectedDate = date;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select meal type',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<MealType>(
                        isExpanded: true,
                        value: selectedMealType,
                        items: MealType.values.map((MealType mealType) {
                          return DropdownMenuItem<MealType>(
                            value: mealType,
                            child: Row(
                              children: [
                                Text(mealType.emoji),
                                const SizedBox(width: 8),
                                Text(mealType.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (MealType? newValue) {
                          if (newValue != null) {
                            selectedMealType = newValue;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Servings: $_servings',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<MealPlanProvider>().addMealToPlan(
                  selectedDate,
                  recipe,
                  selectedMealType,
                  _servings,
                );
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${recipe.title} to meal plan for ${selectedMealType.displayName.toLowerCase()}'),
                    action: SnackBarAction(
                      label: 'View',
                      onPressed: () {
                        // Navigate to meal plan screen
                        // This would be implemented in a real app
                      },
                    ),
                  ),
                );
              },
              child: const Text('Add to Meal Plan'),
            ),
          ],
        );
      },
    );
  }
}
