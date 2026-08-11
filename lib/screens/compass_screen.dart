import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  String _getDirection(double? heading) {
    if (heading == null) return '--';

    // Normalize heading to 0-360
    double h = heading % 360;
    if (h < 0) h += 360;

    if (h >= 337.5 || h < 22.5) return 'N';
    if (h >= 22.5 && h < 67.5) return 'NE';
    if (h >= 67.5 && h < 112.5) return 'E';
    if (h >= 112.5 && h < 157.5) return 'SE';
    if (h >= 157.5 && h < 202.5) return 'S';
    if (h >= 202.5 && h < 247.5) return 'SW';
    if (h >= 247.5 && h < 292.5) return 'W';
    if (h >= 292.5 && h < 337.5) return 'NW';
    return '--';
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
          // We convert angle to fraction of a circle (turns)
          double turns = direction / 360.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${direction.toStringAsFixed(0)}°',
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
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass dial
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 4,
                        ),
                      ),
                      child: Stack(
                        children: [
                          _buildDialMark(0, 'N', theme, true),
                          _buildDialMark(90, 'E', theme),
                          _buildDialMark(180, 'S', theme),
                          _buildDialMark(270, 'W', theme),
                          for (int i = 0; i < 360; i += 30)
                            if (i % 90 != 0) _buildTickMark(i, theme)
                        ],
                      ),
                    ),
                    // Compass needle
                    AnimatedRotation(
                      turns: -turns,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: CustomPaint(
                        size: const Size(20, 200),
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

  Widget _buildDialMark(int angle, String label, ThemeData theme, [bool isNorth = false]) {
    return Positioned.fill(
      child: Transform.rotate(
        angle: angle * (math.pi / 180),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isNorth ? Colors.red : theme.colorScheme.onBackground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTickMark(int angle, ThemeData theme) {
    return Positioned.fill(
      child: Transform.rotate(
        angle: angle * (math.pi / 180),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            width: 2,
            height: 10,
            color: theme.colorScheme.onBackground.withOpacity(0.5),
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
