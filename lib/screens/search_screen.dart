import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../app_theme.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../screens/recipe_detail_screen.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_dialog.dart';

class SearchScreen extends StatefulWidget {
  final Map<String, bool>? initialFilter;
  
  const SearchScreen({
    Key? key,
    this.initialFilter,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'maxCookingTime': null,
    'dietType': null,
    'difficulty': null,
    'categories': <String>[],
  };
  bool _isFilterApplied = false;
  
  @override
  void initState() {
    super.initState();
    // Apply initial filter if provided
    if (widget.initialFilter != null) {
      _applyInitialFilter();
    }
  }
  
  void _applyInitialFilter() {
    widget.initialFilter!.forEach((key, value) {
      if (value) {
        switch (key) {
          case 'Quick':
            _filters['maxCookingTime'] = 20;
            break;
          case 'Healthy':
            _filters['categories'] = ['healthy'];
            break;
          case 'Popular':
            // This is handled separately in _buildResults()
            break;
          case 'Breakfast':
          case 'Lunch':
          case 'Dinner':
          case 'Snacks':
          case 'Desserts':
            _filters['categories'] = [key.toLowerCase()];
            break;
          case 'Vegetarian':
            _filters['dietType'] = DietType.vegetarian;
            break;
        }
      }
    });
    
    if (widget.initialFilter!.isNotEmpty) {
      _isFilterApplied = true;
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _isFilterApplied,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search recipes or ingredients',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade100
              : Colors.grey.shade800,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }
  
  Widget _buildResults() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        if (recipeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        List<Recipe> recipes;
        
        // Check if we need to apply a special filter from the initial filter
        if (widget.initialFilter != null && widget.initialFilter!['Popular'] == true) {
          recipes = recipeProvider.popularRecipes;
        } else {
          // First apply search query
          if (_searchQuery.isNotEmpty) {
            recipes = recipeProvider.searchRecipes(_searchQuery);
          } else {
            recipes = recipeProvider.recipes;
          }
          
          // Then apply filters
          if (_isFilterApplied) {
            recipes = recipeProvider.filterRecipes(
              maxCookingTime: _filters['maxCookingTime'],
              dietType: _filters['dietType'],
              difficulty: _filters['difficulty'],
              categories: _filters['categories'],
            );
          }
        }
        
        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No recipes found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_isFilterApplied)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filters'),
                      onPressed: () {
                        setState(() {
                          _filters = {
                            'maxCookingTime': null,
                            'dietType': null,
                            'difficulty': null,
                            'categories': <String>[],
                          };
                          _isFilterApplied = false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        }
        
        return MasonryGridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: recipes.length,
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
        );
      },
    );
  }
  
  void _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => RecipeFilterDialog(initialFilters: _filters),
    );
    
    if (result != null) {
      setState(() {
        _filters = result;
        _isFilterApplied = true;
      });
    }
  }
}
