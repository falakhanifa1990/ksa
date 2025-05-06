import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/constants.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  
  const CategoryCard({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lowercaseTitle = title.toLowerCase();
    
    // Default icon and color if the category is not in the predefined list
    IconData iconData = Icons.restaurant;
    Color color = AppTheme.primaryColor;
    
    // Try to get the icon and color from constants
    if (AppConstants.categoryIcons.containsKey(lowercaseTitle)) {
      iconData = AppConstants.categoryIcons[lowercaseTitle]!;
    }
    
    if (AppConstants.categoryColors.containsKey(lowercaseTitle)) {
      color = AppConstants.categoryColors[lowercaseTitle]!;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
