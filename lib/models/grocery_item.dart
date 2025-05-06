import 'dart:convert';

class GroceryItem {
  final String id;
  final String name;
  final String category;
  final String? recipeId;  // Recipe this item came from, if applicable
  final String? recipeName;
  final bool isCompleted;
  final double? quantity;
  final String? unit;
  
  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    this.recipeId,
    this.recipeName,
    this.isCompleted = false,
    this.quantity,
    this.unit,
  });

  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? recipeId,
    String? recipeName,
    bool? isCompleted,
    double? quantity,
    String? unit,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      isCompleted: isCompleted ?? this.isCompleted,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'isCompleted': isCompleted ? 1 : 0,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      recipeId: map['recipeId'],
      recipeName: map['recipeName'],
      isCompleted: map['isCompleted'] == 1,
      quantity: map['quantity'],
      unit: map['unit'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GroceryItem.fromJson(String source) => GroceryItem.fromMap(json.decode(source));

  @override
  String toString() {
    if (quantity != null && unit != null) {
      return '$quantity $unit $name';
    } else if (quantity != null) {
      return '$quantity $name';
    } else {
      return name;
    }
  }
}

enum GroceryCategory {
  produce,
  dairy,
  meat,
  bakery,
  pantry,
  frozen,
  beverages,
  other,
}

extension GroceryCategoryExtension on GroceryCategory {
  String get displayName {
    switch (this) {
      case GroceryCategory.produce:
        return 'Produce';
      case GroceryCategory.dairy:
        return 'Dairy';
      case GroceryCategory.meat:
        return 'Meat & Seafood';
      case GroceryCategory.bakery:
        return 'Bakery';
      case GroceryCategory.pantry:
        return 'Pantry';
      case GroceryCategory.frozen:
        return 'Frozen';
      case GroceryCategory.beverages:
        return 'Beverages';
      case GroceryCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case GroceryCategory.produce:
        return '🥦';
      case GroceryCategory.dairy:
        return '🥛';
      case GroceryCategory.meat:
        return '🥩';
      case GroceryCategory.bakery:
        return '🍞';
      case GroceryCategory.pantry:
        return '🥫';
      case GroceryCategory.frozen:
        return '🧊';
      case GroceryCategory.beverages:
        return '🥤';
      case GroceryCategory.other:
        return '🛒';
    }
  }
}
