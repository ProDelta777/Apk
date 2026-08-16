import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  // 16-point wind rose mapping
  String _getDirection(double? heading) {
    if (heading == null) return '--';

    // Normalize heading to 0-360
    double h = heading % 360;
    if (h < 0) h += 360;

    // 360 / 16 = 22.5 degrees per sector. Shift by 11.25 to center the sectors on the exact headings.
    final val = ((h / 22.5) + 0.5).floor() % 16;
    final directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW'
    ];

    return directions[val];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error reading compass sensor:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          double? direction = snapshot.data?.heading;

          if (direction == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore_off, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Compass sensor not available',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your device does not seem to have the required hardware (magnetometer) to use this tool.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Use AnimatedRotation for smoother wrapping around 360/0 boundary
          double turns = direction / 360.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${direction.toStringAsFixed(1)}°', // High accuracy readout
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getDirection(direction),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass dial
                    Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 4,
                        ),
                      ),
                      child: Stack(
                        children: [
                          _buildDialMark(0, 'N', theme, true, true),
                          _buildDialMark(45, 'NE', theme, false, false),
                          _buildDialMark(90, 'E', theme, false, true),
                          _buildDialMark(135, 'SE', theme, false, false),
                          _buildDialMark(180, 'S', theme, false, true),
                          _buildDialMark(225, 'SW', theme, false, false),
                          _buildDialMark(270, 'W', theme, false, true),
                          _buildDialMark(315, 'NW', theme, false, false),
                          for (double i = 0; i < 360; i += 22.5) // 16 ticks
                            if (i % 45 != 0) _buildTickMark(i, theme)
                        ],
                      ),
                    ),
                    // Compass needle
                    AnimatedRotation(
                      turns: -turns,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: CustomPaint(
                        size: const Size(20, 220),
                        painter: _CompassNeedlePainter(theme.colorScheme.primary),
                      ),
                    ),
                    // Center dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onBackground,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              if (snapshot.data?.accuracy != null && snapshot.data!.accuracy! == 1) // 1 == low accuracy in Android SensorManager
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Calibration needed (figure 8)',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialMark(double angle, String label, ThemeData theme, bool isNorth, bool isPrimary) {
    return Positioned.fill(
      child: Transform.rotate(
        angle: angle * (math.pi / 180),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: isPrimary ? 8.0 : 12.0),
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                fontSize: isPrimary ? null : 12,
                color: isNorth ? Colors.red : (isPrimary ? theme.colorScheme.onBackground : theme.colorScheme.onBackground.withOpacity(0.6)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTickMark(double angle, ThemeData theme) {
    return Positioned.fill(
      child: Transform.rotate(
        angle: angle * (math.pi / 180),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            width: 2,
            height: 8,
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

class _CompassNeedlePainter extends CustomPainter {
  final Color primaryColor;

  _CompassNeedlePainter(this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // North pointer (red)
    final pathN = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height / 2)
      ..close();

    paint.color = Colors.red;
    canvas.drawPath(pathN, paint);

    // South pointer
    final pathS = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height / 2)
      ..close();

    paint.color = Colors.grey.shade400;
    canvas.drawPath(pathS, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
