import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'providers/meal_plan_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => MealPlanProvider()),
    ],
    child: const AirfryerRecipeApp(),
  ));
}

class AirfryerRecipeApp extends StatelessWidget {
  const AirfryerRecipeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Airfryer Recipes',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const MealPlannerScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize data
    Future.delayed(Duration.zero, () {
      context.read<RecipeProvider>().initializeRecipes();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
