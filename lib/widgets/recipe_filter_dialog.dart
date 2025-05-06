import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';

class RecipeFilterDialog extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  
  const RecipeFilterDialog({
    Key? key,
    required this.initialFilters,
  }) : super(key: key);

  @override
  State<RecipeFilterDialog> createState() => _RecipeFilterDialogState();
}

class _RecipeFilterDialogState extends State<RecipeFilterDialog> {
  late int? _maxCookingTime;
  late DietType? _dietType;
  late String? _difficulty;
  late List<String> _categories;
  
  @override
  void initState() {
    super.initState();
    _maxCookingTime = widget.initialFilters['maxCookingTime'];
    _dietType = widget.initialFilters['dietType'];
    _difficulty = widget.initialFilters['difficulty'];
    _categories = List<String>.from(widget.initialFilters['categories'] ?? []);
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filter Recipes'),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildCookingTimeFilter(),
            const Divider(),
            _buildDietTypeFilter(),
            const Divider(),
            _buildDifficultyFilter(),
            const Divider(),
            _buildCategoriesFilter(),
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
            final filters = {
              'maxCookingTime': _maxCookingTime,
              'dietType': _dietType,
              'difficulty': _difficulty,
              'categories': _categories,
            };
            Navigator.pop(context, filters);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
  
  Widget _buildCookingTimeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cooking Time',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Any',
              selected: _maxCookingTime == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _maxCookingTime = null;
                  });
                }
              },
            ),
            _buildFilterChip(
              label: '≤ 15 min',
              selected: _maxCookingTime == 15,
              onSelected: (selected) {
                setState(() {
                  _maxCookingTime = selected ? 15 : null;
                });
              },
            ),
            _buildFilterChip(
              label: '≤ 30 min',
              selected: _maxCookingTime == 30,
              onSelected: (selected) {
                setState(() {
                  _maxCookingTime = selected ? 30 : null;
                });
              },
            ),
            _buildFilterChip(
              label: '≤ 45 min',
              selected: _maxCookingTime == 45,
              onSelected: (selected) {
                setState(() {
                  _maxCookingTime = selected ? 45 : null;
                });
              },
            ),
            _buildFilterChip(
              label: '≤ 60 min',
              selected: _maxCookingTime == 60,
              onSelected: (selected) {
                setState(() {
                  _maxCookingTime = selected ? 60 : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDietTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diet Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Any',
              selected: _dietType == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _dietType = null;
                  });
                }
              },
            ),
            ...DietType.values.map((dietType) {
              return _buildFilterChip(
                label: AppConstants.dietTypeNames[dietType] ?? dietType.toString().split('.').last,
                selected: _dietType == dietType,
                onSelected: (selected) {
                  setState(() {
                    _dietType = selected ? dietType : null;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDifficultyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'Any',
              selected: _difficulty == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _difficulty = null;
                  });
                }
              },
            ),
            ...AppConstants.difficulties.map((difficulty) {
              return _buildFilterChip(
                label: difficulty,
                selected: _difficulty == difficulty,
                onSelected: (selected) {
                  setState(() {
                    _difficulty = selected ? difficulty : null;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCategoriesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.recipeCategories.map((category) {
            return _buildFilterChip(
              label: category,
              selected: _categories.contains(category),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _categories.add(category);
                  } else {
                    _categories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : Colors.grey[700],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: selected ? AppTheme.primaryColor : null,
        fontWeight: selected ? FontWeight.bold : null,
      ),
    );
  }
  
  void _clearAllFilters() {
    setState(() {
      _maxCookingTime = null;
      _dietType = null;
      _difficulty = null;
      _categories = [];
    });
  }
}
