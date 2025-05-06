import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../models/meal_plan.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/recipe_provider.dart';
import '../screens/grocery_list_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../widgets/custom_app_bar.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize meal plans if not already done
    Future.delayed(Duration.zero, () {
      final mealPlanProvider = context.read<MealPlanProvider>();
      if (mealPlanProvider.mealPlans.isEmpty) {
        mealPlanProvider.initializeMealPlans();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Meal Planner',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroceryListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(),
          _buildSelectedDayInfo(),
          Expanded(
            child: _buildMealPlan(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        markerDecoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      eventLoader: (day) {
        // Mark days with meal plans
        final mealPlanProvider = context.read<MealPlanProvider>();
        return mealPlanProvider.getMealPlanForDate(day) != null ? [1] : [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
    );
  }
  
  Widget _buildSelectedDayInfo() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(_selectedDay),
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMealPlan() {
    return Consumer<MealPlanProvider>(
      builder: (context, mealPlanProvider, child) {
        if (mealPlanProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final mealPlan = mealPlanProvider.getMealPlanForDate(_selectedDay);
        
        if (mealPlan == null || mealPlan.meals.isEmpty) {
          return _buildEmptyMealPlan();
        }
        
        // Group meals by meal type
        final groupedMeals = <MealType, List<MealEntry>>{};
        for (final mealType in MealType.values) {
          groupedMeals[mealType] = mealPlan.meals
              .where((meal) => meal.mealType == mealType)
              .toList();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: MealType.values.length,
          itemBuilder: (context, index) {
            final mealType = MealType.values[index];
            final meals = groupedMeals[mealType] ?? [];
            
            return _buildMealTypeSection(mealType, meals, mealPlan.id);
          },
        );
      },
    );
  }
  
  Widget _buildEmptyMealPlan() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 72,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Meals Planned',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add recipes to your meal plan for this day',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add a Meal'),
            onPressed: () {
              // Navigate to home screen to select a recipe
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildMealTypeSection(MealType mealType, List<MealEntry> meals, String mealPlanId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              mealType.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              mealType.displayName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (meals.isEmpty)
          Card(
            child: InkWell(
              onTap: () {
                // Navigate to recipe selection for this meal type
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text('Add a meal'),
                  ],
                ),
              ),
            ),
          )
        else
          ...meals.map((meal) => _buildMealCard(meal, mealPlanId)).toList(),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildMealCard(MealEntry meal, String mealPlanId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipeId: meal.recipeId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.recipeName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Servings: ${meal.servings}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _showRemoveMealDialog(context, meal, mealPlanId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showRemoveMealDialog(BuildContext context, MealEntry meal, String mealPlanId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Meal'),
          content: Text(
            'Are you sure you want to remove ${meal.recipeName} from your meal plan?',
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
                context.read<MealPlanProvider>().removeMealFromPlan(mealPlanId, meal.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
