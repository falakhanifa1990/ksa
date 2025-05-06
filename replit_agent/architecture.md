# Architecture Documentation

## Overview

The Airfryer Recipes application is a comprehensive Flutter-based mobile app that provides users with airfryer recipes, meal planning features, and grocery list management. The app follows a client-side architecture with local data persistence.

The application uses the Provider pattern for state management, SQLite for local data storage, and follows a feature-based organization approach with clear separation of concerns.

## System Architecture

### Client Architecture

The application follows the Provider pattern for state management, which is a simplified implementation of the MVVM (Model-View-ViewModel) architecture:

```
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│     Views     │     │   Providers   │     │     Models    │
│  (Screens &   │◄────┤  (ViewModels) │◄────┤ (Data Models) │
│    Widgets)   │     │               │     │               │
└───────────────┘     └───────────────┘     └───────────────┘
        ▲                     ▲                     ▲
        │                     │                     │
        │                     │                     │
        │                     ▼                     │
        │             ┌───────────────┐             │
        │             │   Services    │             │
        └─────────────┤ (Data Access) ├─────────────┘
                      │               │
                      └───────────────┘
                             ▲
                             │
                             ▼
                      ┌───────────────┐
                      │  Local Data   │
                      │  (SQLite DB)  │
                      │               │
                      └───────────────┘
```

## Key Components

### 1. UI Layer

The UI layer is organized into screens and reusable widgets:

- **Screens**: Implement full application views (e.g., `home_screen.dart`, `recipe_detail_screen.dart`)
- **Widgets**: Reusable UI components (e.g., `recipe_card.dart`, `category_card.dart`)

The app uses a consistent design system defined in `app_theme.dart` which provides colors, typography, and other styling constants for both light and dark themes.

### 2. State Management

State management is implemented using the Provider package with several ChangeNotifier classes:

- **RecipeProvider**: Manages recipe data, favorites, and filtering
- **UserProvider**: Handles user preferences and settings
- **MealPlanProvider**: Manages meal plans and grocery lists
- **ThemeProvider**: Controls app theme settings

These providers are registered at the app's entry point in `main.dart`, making them accessible throughout the widget tree.

### 3. Data Models

Data models are defined as immutable classes with JSON serialization/deserialization:

- **Recipe**: Recipe details including ingredients, steps, and nutritional information
- **User**: User profile and preferences
- **MealPlan**: Meal planning data structure
- **GroceryItem**: Shopping list items

### 4. Data Persistence

The app uses SQLite (via `sqflite` package) for structured data storage and `shared_preferences` for simple key-value storage:

- **DatabaseService**: Handles all database operations, including initialization, CRUD operations, and queries

## Data Flow

1. **Recipe Browsing Flow**:
   - User navigates to Home Screen
   - RecipeProvider loads recipes from DatabaseService
   - UI components display filtered/categorized recipes
   - User can view details, add to favorites, or add to meal plan

2. **Meal Planning Flow**:
   - User navigates to Meal Planner Screen
   - MealPlanProvider retrieves meal plans for selected dates
   - User can add/remove recipes from meal plan
   - System generates grocery list items based on meal plans

3. **Settings Flow**:
   - User navigates to Settings Screen
   - UserProvider loads/saves user preferences
   - ThemeProvider applies theme changes system-wide

## External Dependencies

The application relies on several key Flutter packages:

- **State Management**: provider (^6.0.5)
- **Local Storage**: sqflite (^2.2.8+4), shared_preferences (^2.1.1)
- **UI Components**: flutter_staggered_grid_view (^0.6.2), carousel_slider (^4.2.1), flutter_rating_bar (^4.0.1)
- **Utilities**: intl (^0.18.1), uuid (^3.0.7)
- **Media Handling**: cached_network_image (^3.2.3), image_picker (^0.8.7+5)
- **Animations**: animations (^2.0.7), loading_animation_widget (^1.2.0+4), lottie (^2.4.0)

## Deployment Strategy

The application is configured for deployment to multiple platforms including web:

1. **Web Deployment**:
   - The project is configured to run on a web server on port 5000
   - The deployment commands are defined in `.replit` file

2. **Mobile Deployment**:
   - The app can be deployed to mobile platforms using standard Flutter build commands
   - Flutter version management is handled through the Flutter SDK configuration

3. **CI/CD**:
   - The repository includes workflow configurations that enable automated builds

## Future Considerations

1. **Backend Integration**:
   - The current architecture is prepared for potential backend integration with HTTP client support
   - The app could be extended to sync data with a remote server

2. **Offline Support**:
   - The app currently operates with local data storage, making it inherently offline-capable
   - Additional caching strategies could be implemented for external resources

3. **Authentication**:
   - The UserProvider is designed to support authentication in the future
   - Additional security measures would be needed for remote API integration