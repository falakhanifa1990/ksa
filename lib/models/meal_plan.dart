import 'dart:convert';

class MealPlan {
  final String id;
  final DateTime date;
  final List<MealEntry> meals;
  
  MealPlan({
    required this.id,
    required this.date,
    required this.meals,
  });

  MealPlan copyWith({
    String? id,
    DateTime? date,
    List<MealEntry>? meals,
  }) {
    return MealPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      meals: meals ?? this.meals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'meals': meals.map((x) => x.toMap()).toList(),
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      meals: List<MealEntry>.from(map['meals']?.map((x) => MealEntry.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory MealPlan.fromJson(String source) => MealPlan.fromMap(json.decode(source));
}

class MealEntry {
  final String id;
  final String recipeId;
  final String recipeName;
  final String imageUrl;
  final MealType mealType;
  final int servings;
  
  MealEntry({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    required this.imageUrl,
    required this.mealType,
    required this.servings,
  });

  MealEntry copyWith({
    String? id,
    String? recipeId,
    String? recipeName,
    String? imageUrl,
    MealType? mealType,
    int? servings,
  }) {
    return MealEntry(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      imageUrl: imageUrl ?? this.imageUrl,
      mealType: mealType ?? this.mealType,
      servings: servings ?? this.servings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'imageUrl': imageUrl,
      'mealType': mealType.toString().split('.').last,
      'servings': servings,
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'],
      recipeId: map['recipeId'],
      recipeName: map['recipeName'],
      imageUrl: map['imageUrl'],
      mealType: MealType.values.firstWhere(
        (e) => e.toString().split('.').last == map['mealType'],
        orElse: () => MealType.lunch,
      ),
      servings: map['servings'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MealEntry.fromJson(String source) => MealEntry.fromMap(json.decode(source));
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🍳';
      case MealType.lunch:
        return '🥗';
      case MealType.dinner:
        return '🍲';
      case MealType.snack:
        return '🍿';
    }
  }
}
