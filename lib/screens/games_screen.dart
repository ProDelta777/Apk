import 'package:flutter/material.dart';
import '../games/find_it_game.dart';
import '../games/quick_tap_game.dart';
import '../games/memory_game.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Games'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _GameCard(
            title: 'Find It',
            description: 'Test your visual scanning by finding the requested object.',
            icon: Icons.search,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FindItGame())),
            theme: theme,
          ),
          const SizedBox(height: 16),
          _GameCard(
            title: 'Quick Tap',
            description: 'Test your reflexes by tapping targets as fast as possible.',
            icon: Icons.touch_app,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickTapGame())),
            theme: theme,
          ),
          const SizedBox(height: 16),
          _GameCard(
            title: 'Memory Match',
            description: 'Test your short-term memory by finding matching pairs.',
            icon: Icons.grid_view,
            color: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGame())),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final ThemeData theme;

  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
