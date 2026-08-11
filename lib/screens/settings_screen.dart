import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/theme_provider.dart';
import '../providers/progress_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Preferences'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Developer aesthetic'),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                secondary: Icon(themeProvider.isDarkMode ? LucideIcons.moon : LucideIcons.sun),
                activeColor: Theme.of(context).primaryColor,
              );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.languages),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('More languages coming soon!'))
               );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.bell),
            title: const Text('Notifications'),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Notifications toggled!'))
                 );
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Data & Progress'),
          ListTile(
            leading: const Icon(LucideIcons.refreshCw, color: Colors.red),
            title: const Text('Reset Progress', style: TextStyle(color: Colors.red)),
            subtitle: const Text('This action cannot be undone.'),
            onTap: () => _showResetConfirmation(context),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(LucideIcons.info),
            title: Text('About PRECODE'),
            subtitle: Text('Offline programming education.'),
          ),
          const ListTile(
            leading: Icon(LucideIcons.shield),
            title: Text('Privacy Policy'),
            subtitle: Text('All data is stored locally.'),
          ),
          const ListTile(
            leading: Icon(LucideIcons.smartphone),
            title: Text('App Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('Are you sure you want to delete all your learning progress? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProgressProvider>().resetProgress();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset successfully.'))
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
