import 'dart:convert';

class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final List<CookingStep> cookingSteps;
  final int cookingTimeMinutes;
  final int servings;
  final String difficulty;
  final DietType dietType;
  final double temperature;
  final Nutrition? nutrition;
  final List<String> categories;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final bool hasVideo;
  final String? videoUrl;
  
  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.ingredients,
    required this.cookingSteps,
    required this.cookingTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.dietType,
    required this.temperature,
    this.nutrition,
    required this.categories,
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.hasVideo = false,
    this.videoUrl,
  });

  bool get isQuickAndEasy => cookingTimeMinutes <= 20;
  
  Recipe copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? description,
    List<String>? ingredients,
    List<CookingStep>? cookingSteps,
    int? cookingTimeMinutes,
    int? servings,
    String? difficulty,
    DietType? dietType,
    double? temperature,
    Nutrition? nutrition,
    List<String>? categories,
    bool? isFeatured,
    double? rating,
    int? reviewCount,
    bool? hasVideo,
    String? videoUrl,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      cookingSteps: cookingSteps ?? this.cookingSteps,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      dietType: dietType ?? this.dietType,
      temperature: temperature ?? this.temperature,
      nutrition: nutrition ?? this.nutrition,
      categories: categories ?? this.categories,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      hasVideo: hasVideo ?? this.hasVideo,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'ingredients': ingredients,
      'cookingSteps': cookingSteps.map((x) => x.toMap()).toList(),
      'cookingTimeMinutes': cookingTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'dietType': dietType.toString().split('.').last,
      'temperature': temperature,
      'nutrition': nutrition?.toMap(),
      'categories': categories,
      'isFeatured': isFeatured ? 1 : 0,
      'rating': rating,
      'reviewCount': reviewCount,
      'hasVideo': hasVideo ? 1 : 0,
      'videoUrl': videoUrl,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      ingredients: List<String>.from(map['ingredients']),
      cookingSteps: List<CookingStep>.from(
        map['cookingSteps']?.map((x) => CookingStep.fromMap(x))
      ),
      cookingTimeMinutes: map['cookingTimeMinutes'],
      servings: map['servings'],
      difficulty: map['difficulty'],
      dietType: DietType.values.firstWhere(
        (e) => e.toString().split('.').last == map['dietType'],
        orElse: () => DietType.regular,
      ),
      temperature: map['temperature'],
      nutrition: map['nutrition'] != null ? Nutrition.fromMap(map['nutrition']) : null,
      categories: List<String>.from(map['categories']),
      isFeatured: map['isFeatured'] == 1,
      rating: map['rating'],
      reviewCount: map['reviewCount'],
      hasVideo: map['hasVideo'] == 1,
      videoUrl: map['videoUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Recipe.fromJson(String source) => Recipe.fromMap(json.decode(source));
}

class CookingStep {
  final int stepNumber;
  final String instruction;
  final int? timerMinutes;
  final String? image;
  
  CookingStep({
    required this.stepNumber,
    required this.instruction,
    this.timerMinutes,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      'timerMinutes': timerMinutes,
      'image': image,
    };
  }

  factory CookingStep.fromMap(Map<String, dynamic> map) {
    return CookingStep(
      stepNumber: map['stepNumber'],
      instruction: map['instruction'],
      timerMinutes: map['timerMinutes'],
      image: map['image'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CookingStep.fromJson(String source) => CookingStep.fromMap(json.decode(source));
}

class Nutrition {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  
  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
  });

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
    };
  }

  factory Nutrition.fromMap(Map<String, dynamic> map) {
    return Nutrition(
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      fiber: map['fiber'],
      sugar: map['sugar'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Nutrition.fromJson(String source) => Nutrition.fromMap(json.decode(source));
}

enum DietType {
  regular,
  vegan,
  vegetarian,
  ketogenic,
  glutenFree,
  dairyFree,
  lowCalorie,
  lowCarb,
  highProtein,
}

enum RecipeCategory {
  breakfast,
  lunch,
  dinner,
  snacks,
  desserts,
  sides,
  mains,
  healthy,
  quickAndEasy,
}

class Review {
  final String id;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  
  Review({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      recipeId: map['recipeId'],
      userId: map['userId'],
      userName: map['userName'],
      userPhotoUrl: map['userPhotoUrl'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Review.fromJson(String source) => Review.fromMap(json.decode(source));
}
