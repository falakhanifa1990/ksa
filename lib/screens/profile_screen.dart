import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../screens/settings_screen.dart';
import '../widgets/custom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final user = userProvider.currentUser;
          
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),
                _buildSettingsSection(context),
                const SizedBox(height: 16),
                _buildPreferencesSection(context, user, userProvider),
                const SizedBox(height: 16),
                _buildAboutSection(context),
                const SizedBox(height: 24),
                _buildFooter(context),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileHeader(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor,
            child: user.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.photoUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            onPressed: () {
              _showEditProfileDialog(context, user);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings, color: AppTheme.primaryColor),
                  title: const Text('App Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications, color: AppTheme.primaryColor),
                  title: const Text('Notifications'),
                  trailing: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return Switch(
                        value: userProvider.appSettings.notificationsEnabled,
                        onChanged: (value) {
                          userProvider.toggleNotifications();
                        },
                        activeColor: AppTheme.primaryColor,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download, color: AppTheme.primaryColor),
                  title: const Text('Offline Access'),
                  trailing: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return Switch(
                        value: userProvider.appSettings.offlineDownloadsEnabled,
                        onChanged: (value) {
                          userProvider.toggleOfflineDownloads();
                        },
                        activeColor: AppTheme.primaryColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreferencesSection(BuildContext context, User user, UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Dietary Preferences',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.dietaryPreferences.isEmpty
                        ? [
                            const Chip(
                              label: Text('No preferences set'),
                              backgroundColor: Colors.grey,
                            ),
                          ]
                        : user.dietaryPreferences
                            .map((pref) => Chip(
                                  label: Text(pref),
                                  backgroundColor: AppTheme.primaryColor,
                                  labelStyle: const TextStyle(color: Colors.white),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  onDeleted: () {
                                    final newPreferences = List<String>.from(user.dietaryPreferences);
                                    newPreferences.remove(pref);
                                    userProvider.updateUser(
                                      dietaryPreferences: newPreferences,
                                    );
                                  },
                                ))
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Preference'),
                    onPressed: () {
                      _showAddPreferenceDialog(context, user, userProvider);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: AppTheme.primaryColor),
                  title: const Text('About This App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star, color: AppTheme.primaryColor),
                  title: const Text('Rate the App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // This would link to app store in a real app
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rating feature not implemented in this demo')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback, color: AppTheme.primaryColor),
                  title: const Text('Send Feedback'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showFeedbackDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Airfryer Recipes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  void _showEditProfileDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
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
                if (nameController.text.trim().isNotEmpty && 
                    emailController.text.trim().isNotEmpty) {
                  context.read<UserProvider>().updateUser(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddPreferenceDialog(BuildContext context, User user, UserProvider userProvider) {
    final allDietTypes = [
      'Vegetarian',
      'Vegan',
      'Gluten-Free',
      'Dairy-Free',
      'Keto',
      'Low-Carb',
      'Low-Calorie',
      'High-Protein',
      'Paleo',
      'Nut-Free',
    ];
    
    final availablePreferences = allDietTypes
        .where((pref) => !user.dietaryPreferences.contains(pref))
        .toList();
    
    if (availablePreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All preferences are already added')),
      );
      return;
    }
    
    String selectedPreference = availablePreferences.first;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Dietary Preference'),
              content: DropdownButtonFormField<String>(
                value: selectedPreference,
                decoration: const InputDecoration(
                  labelText: 'Preference',
                ),
                items: availablePreferences.map((pref) {
                  return DropdownMenuItem<String>(
                    value: pref,
                    child: Text(pref),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPreference = value;
                    });
                  }
                },
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
                    final newPreferences = List<String>.from(user.dietaryPreferences)
                      ..add(selectedPreference);
                    userProvider.updateUser(
                      dietaryPreferences: newPreferences,
                    );
                    Navigator.pop(context);
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
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Airfryer Recipes'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Airfryer Recipes is your go-to app for delicious, healthy, and quick recipes specifically designed for air fryers.',
                ),
                SizedBox(height: 16),
                Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Hundreds of air fryer recipes'),
                Text('• Step-by-step cooking instructions'),
                Text('• Meal planning and grocery lists'),
                Text('• Favorites and reviews system'),
                Text('• Cooking timer integration'),
                Text('• Offline access to saved recipes'),
                SizedBox(height: 16),
                Text(
                  'We hope you enjoy using our app!',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We\'d love to hear your thoughts on how we can improve the app!',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Feedback',
                    hintText: 'Share your thoughts, ideas, or report issues...',
                  ),
                  maxLines: 5,
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
                if (feedbackController.text.trim().isNotEmpty) {
                  // This would send feedback in a real app
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your feedback!')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
