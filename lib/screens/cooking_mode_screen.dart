import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../models/recipe.dart';
import '../widgets/timer_widget.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;
  final int servings;
  
  const CookingModeScreen({
    Key? key,
    required this.recipe,
    required this.servings,
  }) : super(key: key);

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  bool _keepScreenOn = true;
  Timer? _totalTimer;
  int _totalTimeRemaining = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Set the screen to stay on
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Calculate total time
    _totalTimeRemaining = widget.recipe.cookingTimeMinutes * 60;
    _startTotalTimer();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _totalTimer?.cancel();
    
    // Restore normal system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    
    super.dispose();
  }
  
  void _startTotalTimer() {
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_totalTimeRemaining > 0) {
          _totalTimeRemaining--;
        } else {
          _totalTimer?.cancel();
        }
      });
    });
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentStep = index;
              });
            },
            children: [
              // Prep Step
              _buildPrepStep(),
              
              // Cooking Steps
              ...widget.recipe.cookingSteps.map((step) => _buildCookingStep(step)).toList(),
              
              // Completion Step
              _buildCompletionStep(),
            ],
          ),
          
          // Top Bar
          SafeArea(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _showExitConfirmationDialog();
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.recipe.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Step ${_currentStep > 0 && _currentStep <= widget.recipe.cookingSteps.length ? _currentStep : 'Prep'} of ${widget.recipe.cookingSteps.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_totalTimeRemaining),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      _keepScreenOn ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _keepScreenOn = !_keepScreenOn;
                      });
                      if (_keepScreenOn) {
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                      } else {
                        SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.manual,
                          overlays: SystemUiOverlay.values,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentStep > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Previous'),
                    ),
                    // Step Indicator
                    Row(
                      children: [
                        for (int i = 0; i < widget.recipe.cookingSteps.length + 2; i++)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _currentStep
                                  ? AppTheme.primaryColor
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _currentStep < widget.recipe.cookingSteps.length + 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _currentStep < widget.recipe.cookingSteps.length
                            ? 'Next'
                            : 'Finish',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrepStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preparation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thermostat, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Preheat your air fryer to ${widget.recipe.temperature}°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gather these ingredients:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.recipe.ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = widget.recipe.ingredients[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Equipment needed:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Air fryer',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Measuring cups and spoons',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mixing bowls',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'When you\'re ready, press "Next" to start cooking!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCookingStep(CookingStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${step.stepNumber}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (step.image != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(step.image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                if (step.timerMinutes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 16),
                        TimerWidget(minutes: step.timerMinutes!),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompletionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.primaryColor,
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You\'ve completed ${widget.recipe.title}',
            style: const TextStyle(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enjoy your meal!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tips for serving:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Let the food rest for a few minutes before serving\n'
                  '• Garnish with fresh herbs if available\n'
                  '• Serve immediately for best taste and texture',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                if (widget.recipe.nutrition != null) ...[
                  const Text(
                    'Nutrition per serving:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionItem(
                        'Calories',
                        '${widget.recipe.nutrition!.calories}',
                        'kcal',
                      ),
                      _buildNutritionItem(
                        'Protein',
                        '${widget.recipe.nutrition!.protein}',
                        'g',
                      ),
                      _buildNutritionItem(
                        'Carbs',
                        '${widget.recipe.nutrition!.carbs}',
                        'g',
                      ),
                      _buildNutritionItem(
                        'Fat',
                        '${widget.recipe.nutrition!.fat}',
                        'g',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.star),
                label: const Text('Rate Recipe'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share Recipe'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing is not implemented in this demo')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNutritionItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit Cooking Mode?'),
          content: const Text(
            'Are you sure you want to exit cooking mode? Your progress will not be saved.',
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
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit cooking mode
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}
