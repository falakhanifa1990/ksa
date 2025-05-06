import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final appSettings = userProvider.appSettings;
          
          return ListView(
            children: [
              _buildSection(
                context,
                'Appearance',
                [
                  _buildThemeToggle(context),
                  _buildLanguageSetting(context, appSettings),
                ],
              ),
              _buildSection(
                context,
                'App Preferences',
                [
                  _buildNotificationToggle(context, appSettings, userProvider),
                  _buildOfflineToggle(context, appSettings, userProvider),
                  _buildServingSizeSetting(context, appSettings, userProvider),
                ],
              ),
              _buildSection(
                context,
                'Data Management',
                [
                  _buildListTile(
                    context,
                    'Clear Search History',
                    'Remove all your search history',
                    Icons.history,
                    onTap: () {
                      _showClearSearchHistoryDialog(context);
                    },
                  ),
                  _buildListTile(
                    context,
                    'Clear Cache',
                    'Free up space by clearing cached data',
                    Icons.cleaning_services,
                    onTap: () {
                      _showClearCacheDialog(context);
                    },
                  ),
                ],
              ),
              _buildSection(
                context,
                'Account',
                [
                  _buildListTile(
                    context,
                    'Privacy Policy',
                    'Read our privacy policy',
                    Icons.privacy_tip,
                    onTap: () {
                      _showPrivacyPolicyDialog(context);
                    },
                  ),
                  _buildListTile(
                    context,
                    'Terms of Service',
                    'Read our terms of service',
                    Icons.description,
                    onTap: () {
                      _showTermsOfServiceDialog(context);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
  
  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Use dark theme'),
          secondary: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: AppTheme.primaryColor,
          ),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleThemeMode();
          },
          activeColor: AppTheme.primaryColor,
        );
      },
    );
  }
  
  Widget _buildLanguageSetting(BuildContext context, AppSettings appSettings) {
    return ListTile(
      leading: const Icon(Icons.language, color: AppTheme.primaryColor),
      title: const Text('Language'),
      subtitle: Text(_getLanguageName(appSettings.languageCode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showLanguageDialog(context, appSettings.languageCode);
      },
    );
  }
  
  Widget _buildNotificationToggle(
    BuildContext context,
    AppSettings appSettings,
    UserProvider userProvider,
  ) {
    return SwitchListTile(
      title: const Text('Notifications'),
      subtitle: const Text('Receive recipe suggestions and tips'),
      secondary: const Icon(Icons.notifications, color: AppTheme.primaryColor),
      value: appSettings.notificationsEnabled,
      onChanged: (value) {
        userProvider.toggleNotifications();
      },
      activeColor: AppTheme.primaryColor,
    );
  }
  
  Widget _buildOfflineToggle(
    BuildContext context,
    AppSettings appSettings,
    UserProvider userProvider,
  ) {
    return SwitchListTile(
      title: const Text('Offline Access'),
      subtitle: const Text('Save recipes for offline viewing'),
      secondary: const Icon(Icons.offline_bolt, color: AppTheme.primaryColor),
      value: appSettings.offlineDownloadsEnabled,
      onChanged: (value) {
        userProvider.toggleOfflineDownloads();
      },
      activeColor: AppTheme.primaryColor,
    );
  }
  
  Widget _buildServingSizeSetting(
    BuildContext context,
    AppSettings appSettings,
    UserProvider userProvider,
  ) {
    return ListTile(
      leading: const Icon(Icons.people, color: AppTheme.primaryColor),
      title: const Text('Default Serving Size'),
      subtitle: Text('${appSettings.servingSizeDefault} servings'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: appSettings.servingSizeDefault > 1
                ? () {
                    userProvider.updateDefaultServingSize(
                      appSettings.servingSizeDefault - 1,
                    );
                  }
                : null,
          ),
          Text('${appSettings.servingSizeDefault}'),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: appSettings.servingSizeDefault < 10
                ? () {
                    userProvider.updateDefaultServingSize(
                      appSettings.servingSizeDefault + 1,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'it':
        return 'Italian';
      case 'pt':
        return 'Portuguese';
      case 'ru':
        return 'Russian';
      case 'zh':
        return 'Chinese';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      default:
        return 'English';
    }
  }
  
  void _showLanguageDialog(BuildContext context, String currentLanguageCode) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Spanish'},
      {'code': 'fr', 'name': 'French'},
      {'code': 'de', 'name': 'German'},
      {'code': 'it', 'name': 'Italian'},
      {'code': 'pt', 'name': 'Portuguese'},
      {'code': 'ru', 'name': 'Russian'},
      {'code': 'zh', 'name': 'Chinese'},
      {'code': 'ja', 'name': 'Japanese'},
      {'code': 'ko', 'name': 'Korean'},
    ];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                return RadioListTile<String>(
                  title: Text(language['name']!),
                  value: language['code']!,
                  groupValue: currentLanguageCode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<UserProvider>().changeLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                  activeColor: AppTheme.primaryColor,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  void _showClearSearchHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Search History'),
          content: const Text(
            'Are you sure you want to clear your search history? This action cannot be undone.',
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
                // This would clear search history in a real app
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
  
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
            'Are you sure you want to clear cached data? This will free up space but may slow down app performance temporarily.',
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
                // This would clear cache in a real app
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
  
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const SingleChildScrollView(
            child: Text(
              'This is a placeholder for the privacy policy content. In a real app, this would contain the full privacy policy text detailing how user data is collected, used, and protected.\n\n'
              'Key points typically covered in a privacy policy include:\n\n'
              '• What information we collect\n'
              '• How we use your information\n'
              '• How we share your information\n'
              '• How we store and protect your information\n'
              '• Your privacy rights\n'
              '• Updates to this policy\n'
              '• How to contact us about privacy concerns',
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
  
  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms of Service'),
          content: const SingleChildScrollView(
            child: Text(
              'This is a placeholder for the terms of service content. In a real app, this would contain the full terms of service text outlining the rules and guidelines for using the app.\n\n'
              'Key points typically covered in terms of service include:\n\n'
              '• User rights and responsibilities\n'
              '• Acceptable use policy\n'
              '• Intellectual property rights\n'
              '• Limitation of liability\n'
              '• Governing law\n'
              '• Termination of service\n'
              '• Changes to terms\n'
              '• How to contact us about terms questions',
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
}
