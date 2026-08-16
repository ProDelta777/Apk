import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  double _x = 0;
  double _y = 0;
  bool _isLevel = false;
  bool _isSensorAvailable = true;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;
      setState(() {
        _x = event.x;
        _y = event.y;
        // Consider it level if tilt is very small (< 0.5 m/s^2 on x and y)
        _isLevel = _x.abs() < 0.5 && _y.abs() < 0.5;
      });
    }, onError: (e) {
      setState(() {
        _isSensorAvailable = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final xAngle = (_x * 90 / 9.8).clamp(-90.0, 90.0);
    final yAngle = (_y * 90 / 9.8).clamp(-90.0, 90.0);

    return Scaffold(
      backgroundColor: _isLevel ? Colors.green.shade900 : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Digital Level'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: !_isSensorAvailable
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.horizontal_rule, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Sensor Unavailable',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your device does not support accelerometer sensors required for this tool.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      _isLevel ? 'LEVEL' : 'TILTED',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: _isLevel ? Colors.white : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDegreeCard('X', xAngle, theme),
                        const SizedBox(width: 16),
                        _buildDegreeCard('Y', yAngle, theme),
                      ],
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isLevel ? Colors.white54 : (isDark ? Colors.white24 : Colors.black26),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Crosshairs
                        Container(width: 300, height: 1, color: _isLevel ? Colors.white54 : (isDark ? Colors.white24 : Colors.black26)),
                        Container(width: 1, height: 300, color: _isLevel ? Colors.white54 : (isDark ? Colors.white24 : Colors.black26)),
                        // Target center circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isLevel ? Colors.white : theme.colorScheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        // Bubble indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 100),
                          left: 150 - 20 - (_x * 15).clamp(-130, 130), // Center 150 - half width 20 - shift
                          top: 150 - 20 + (_y * 15).clamp(-130, 130),  // inverted y for intuitive movement
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isLevel ? Colors.white : theme.colorScheme.secondary,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                )
                              ]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDegreeCard(String axis, double angle, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _isLevel ? Colors.white12 : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            axis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: _isLevel ? Colors.white70 : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${angle.abs().toStringAsFixed(1)}°',
            style: theme.textTheme.titleLarge?.copyWith(
              color: _isLevel ? Colors.white : theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
