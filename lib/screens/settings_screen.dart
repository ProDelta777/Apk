import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  bool _hapticFeedback = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    });
  }

  Future<void> _resetGameScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('find_it_best');
    await prefs.remove('quick_tap_best');
    await prefs.remove('memory_best');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game scores reset locally.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Preferences', theme),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme across the app'),
            value: _isDarkMode,
            onChanged: (value) async {
              setState(() => _isDarkMode = value);
              OffgridApp.of(context).toggleTheme(value);
            },
          ),
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate on button presses (Games)'),
            value: _hapticFeedback,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hapticFeedback', value);
              setState(() => _hapticFeedback = value);
            },
          ),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound effects (Games)'),
            value: _soundEnabled,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('soundEnabled', value);
              setState(() => _soundEnabled = value);
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Data Management', theme),
          ListTile(
            title: const Text('Reset Game Scores'),
            subtitle: const Text('Clear local best scores'),
            trailing: const Icon(Icons.delete_outline, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Scores?'),
                  content: const Text('This will permanently delete your best scores for all mini games. This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        _resetGameScores();
                      },
                      child: const Text('RESET'),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.blueGrey.withOpacity(0.1) : Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.blueGrey.withOpacity(0.3) : Colors.blueGrey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.privacy_tip, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Privacy & Offline Use',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'OFFGRID is designed to keep your information on your device. Core tools do not require an account, cloud database, or external API.\n\nAll sensor and location data is processed locally. Information is only shared when you explicitly use a share or copy action via Android\'s native systems.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'OFFGRID v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
