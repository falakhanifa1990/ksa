import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../screens/recipe_detail_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Favorites',
        showBackButton: false,
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final favoriteRecipes = recipeProvider.getFavoriteRecipesList();
          
          if (favoriteRecipes.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return _buildFavoritesList(context, favoriteRecipes, recipeProvider);
        },
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 72,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorite Recipes Yet',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Save your favorite recipes for quick access',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Browse Recipes'),
            onPressed: () {
              // Switch to home tab
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildFavoritesList(BuildContext context, List<Recipe> favoriteRecipes, RecipeProvider recipeProvider) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: favoriteRecipes.length,
      itemBuilder: (context, index) {
        final recipe = favoriteRecipes[index];
        
        return Dismissible(
          key: Key('favorite_${recipe.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) {
            recipeProvider.toggleFavorite(recipe.id);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${recipe.title} removed from favorites'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    recipeProvider.toggleFavorite(recipe.id);
                  },
                ),
              ),
            );
          },
          child: RecipeCard(
            recipe: recipe,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
