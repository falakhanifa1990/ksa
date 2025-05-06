import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../app_theme.dart';
import '../models/grocery_item.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_app_bar.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({Key? key}) : super(key: key);

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  String _selectedCategory = GroceryCategory.other.displayName;
  
  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Grocery List',
        showBackButton: true,
      ),
      body: Consumer<MealPlanProvider>(
        builder: (context, mealPlanProvider, child) {
          if (mealPlanProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final groceryItems = mealPlanProvider.groceryItems;
          
          if (groceryItems.isEmpty) {
            return _buildEmptyState();
          }
          
          // Group grocery items by category
          final groupedGroceryItems = <String, List<GroceryItem>>{};
          
          for (final item in groceryItems) {
            if (!groupedGroceryItems.containsKey(item.category)) {
              groupedGroceryItems[item.category] = [];
            }
            groupedGroceryItems[item.category]!.add(item);
          }
          
          // Sort categories
          final sortedCategories = groupedGroceryItems.keys.toList()
            ..sort((a, b) {
              if (a == GroceryCategory.other.displayName) return 1;
              if (b == GroceryCategory.other.displayName) return -1;
              return a.compareTo(b);
            });
          
          return Column(
            children: [
              _buildHeaderSection(mealPlanProvider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final category = sortedCategories[index];
                    final items = groupedGroceryItems[category]!;
                    
                    return _buildCategorySection(
                      category,
                      items,
                      mealPlanProvider,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddItemDialog(context);
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 72,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Your Grocery List is Empty',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your list or generate items from your meal plan',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Items'),
            onPressed: () {
              _showAddItemDialog(context);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeaderSection(MealPlanProvider mealPlanProvider) {
    final completedCount = mealPlanProvider.groceryItems
        .where((item) => item.isCompleted)
        .length;
    final totalCount = mealPlanProvider.groceryItems.length;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Completed: $completedCount/${totalCount}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Clear Completed'),
            onPressed: completedCount > 0
                ? () {
                    _showClearCompletedDialog(context, mealPlanProvider);
                  }
                : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategorySection(
    String category,
    List<GroceryItem> items,
    MealPlanProvider mealPlanProvider,
  ) {
    // Find the grocery category
    final groceryCategory = GroceryCategory.values.firstWhere(
      (element) => element.displayName == category,
      orElse: () => GroceryCategory.other,
    );
    
    final sortedItems = items
      ..sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        return a.name.compareTo(b.name);
      });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              groceryCategory.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...sortedItems.map((item) => _buildGroceryItemTile(
          item,
          mealPlanProvider,
        )).toList(),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildGroceryItemTile(
    GroceryItem item,
    MealPlanProvider mealPlanProvider,
  ) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              mealPlanProvider.removeGroceryItem(item.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (value) {
            mealPlanProvider.toggleGroceryItemCompletion(item.id);
          },
          activeColor: AppTheme.primaryColor,
        ),
        title: Text(
          item.toString(),
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted
                ? Theme.of(context).textTheme.bodySmall?.color
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: item.recipeName != null
            ? Text(
                'From: ${item.recipeName}',
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            mealPlanProvider.removeGroceryItem(item.id);
          },
        ),
      ),
    );
  }
  
  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Grocery Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _itemController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'e.g. Apples',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              hintText: 'e.g. 2',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              hintText: 'e.g. lbs',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: GroceryCategory.values.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.displayName,
                          child: Row(
                            children: [
                              Text(category.icon),
                              const SizedBox(width: 8),
                              Text(category.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
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
                    if (_itemController.text.trim().isNotEmpty) {
                      double? quantity;
                      if (_quantityController.text.isNotEmpty) {
                        quantity = double.tryParse(_quantityController.text);
                      }
                      
                      context.read<MealPlanProvider>().addGroceryItem(
                        _itemController.text.trim(),
                        _selectedCategory,
                        quantity: quantity,
                        unit: _unitController.text.isEmpty
                            ? null
                            : _unitController.text.trim(),
                      );
                      
                      _itemController.clear();
                      _quantityController.clear();
                      _unitController.clear();
                      
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showClearCompletedDialog(BuildContext context, MealPlanProvider mealPlanProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Completed Items'),
          content: const Text(
            'Are you sure you want to remove all completed items from your grocery list?',
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
                mealPlanProvider.clearCompletedGroceryItems();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
  
  void _showGenerateFromMealPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generate Grocery List'),
          content: const Text(
            'Generate grocery items based on your meal plan for the next 7 days?',
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
                final mealPlanProvider = context.read<MealPlanProvider>();
                final recipeProvider = context.read<RecipeProvider>();
                
                // Get meal plans for the next 7 days
                final now = DateTime.now();
                final nextWeek = now.add(const Duration(days: 7));
                
                final mealPlans = mealPlanProvider.mealPlans
                    .where((plan) =>
                        plan.date.isAfter(now.subtract(const Duration(days: 1))) &&
                        plan.date.isBefore(nextWeek))
                    .toList();
                
                mealPlanProvider.generateGroceryListFromMealPlan(
                  mealPlans,
                  recipeProvider.recipes,
                );
                
                Navigator.pop(context);
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }
}
