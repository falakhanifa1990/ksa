import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../app_theme.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/search_screen.dart';
import '../widgets/category_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Desserts',
    'Healthy',
    'Quick',
    'Vegetarian',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Airfryer Recipes',
        showSearchIcon: true,
        onSearchPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        },
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Recipes Carousel
                  if (recipeProvider.featuredRecipes.isNotEmpty) _buildFeaturedCarousel(recipeProvider.featuredRecipes),
                  
                  // Categories
                  _buildCategoriesSection(context),
                  
                  // Popular Recipes Section
                  _buildRecipeSection(
                    context,
                    'Popular Recipes',
                    recipeProvider.popularRecipes,
                    onSeeAllPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(
                            initialFilter: {'Popular': true},
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Quick & Easy Recipes Section
                  _buildRecipeSection(
                    context,
                    'Quick & Easy',
                    recipeProvider.quickAndEasyRecipes,
                    onSeeAllPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(
                            initialFilter: {'Quick': true},
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Healthy Recipes Section
                  _buildRecipeSection(
                    context,
                    'Healthy Meals',
                    recipeProvider.healthyRecipes,
                    onSeeAllPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(
                            initialFilter: {'Healthy': true},
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<Recipe> featuredRecipes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Featured Recipes',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 12),
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              viewportFraction: 0.9,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
            ),
            items: featuredRecipes.map((recipe) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(recipe.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${recipe.cookingTimeMinutes} min',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.star,
                                    color: AppTheme.secondaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    recipe.rating.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return CategoryCard(
                  title: _categories[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          initialFilter: {_categories[index]: true},
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeSection(BuildContext context, String title, List<Recipe> recipes, {VoidCallback? onSeeAllPressed}) {
    if (recipes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                if (onSeeAllPressed != null)
                  TextButton(
                    onPressed: onSeeAllPressed,
                    child: const Text('See All'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              scrollDirection: Axis.horizontal,
              itemCount: recipes.length > 5 ? 5 : recipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(
                  recipe: recipes[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipeId: recipes[index].id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
