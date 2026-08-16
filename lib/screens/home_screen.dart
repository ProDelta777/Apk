import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'compass_screen.dart';
import 'location_screen.dart';
import 'coordinates_screen.dart';
import 'emergency_screen.dart';
import 'flashlight_screen.dart';
import 'level_screen.dart';
import 'device_info_screen.dart';
import 'games_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OFFGRID',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your essential tools. Anywhere.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.green.withOpacity(0.3) : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Offline Ready',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: _tools.length,
                  itemBuilder: (context, index) {
                    final tool = _tools[index];
                    return _ToolCard(
                      tool: tool,
                      onTap: () {
                        if (tool.screen != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => tool.screen!),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tool {
  final String name;
  final String description;
  final IconData icon;
  final Widget? screen;

  const _Tool({
    required this.name,
    required this.description,
    required this.icon,
    this.screen,
  });
}

final _tools = [
  const _Tool(
    name: 'Compass',
    description: '16-point tactical',
    icon: Icons.explore,
    screen: CompassScreen(),
  ),
  const _Tool(
    name: 'My Location',
    description: 'Detailed GPS data',
    icon: Icons.my_location,
    screen: LocationScreen(),
  ),
  const _Tool(
    name: 'Coordinates',
    description: 'Quick GPS share',
    icon: Icons.pin_drop,
    screen: CoordinatesScreen(),
  ),
  const _Tool(
    name: 'Emergency',
    description: 'Critical info',
    icon: Icons.warning,
    screen: EmergencyScreen(),
  ),
  const _Tool(
    name: 'Flashlight',
    description: 'Strobe & SOS',
    icon: Icons.flashlight_on,
    screen: FlashlightScreen(),
  ),
  const _Tool(
    name: 'Level',
    description: 'Digital spirit level',
    icon: Icons.horizontal_rule,
    screen: LevelScreen(),
  ),
  const _Tool(
    name: 'Device Info',
    description: 'Hardware stats',
    icon: Icons.info,
    screen: DeviceInfoScreen(),
  ),
  const _Tool(
    name: 'Mini Games',
    description: 'Offline fun',
    icon: Icons.games,
    screen: GamesScreen(),
  ),
];

class _ToolCard extends StatelessWidget {
  final _Tool tool;
  final VoidCallback onTap;

  const _ToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                tool.icon,
                size: 36,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                tool.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tool.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
