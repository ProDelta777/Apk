import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  bool _isLocked = false;
  double? _lockedHeading;

  // 16-point wind rose mapping
  String _getDirection(double? heading) {
    if (heading == null) return '--';

    double h = heading % 360;
    if (h < 0) h += 360;

    final val = ((h / 22.5) + 0.5).floor() % 16;
    final directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW'
    ];

    return directions[val];
  }

  // Very basic approximation for sun azimuth
  double _getSunAzimuth() {
    final now = DateTime.now();
    final hours = now.hour + (now.minute / 60.0);
    // Rough estimate: Sun is at 180 (South) at noon in Northern Hemisphere.
    // 15 degrees per hour. 6 AM = 90 (East), 6 PM = 270 (West).
    // This is heavily simplified and doesn't account for location.
    double azimuth = 180 + ((hours - 12) * 15.0);
    return azimuth % 360;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
              color: _isLocked ? theme.colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() {
                _isLocked = !_isLocked;
                if (!_isLocked) {
                  _lockedHeading = null;
                }
              });
            },
            tooltip: 'Direction Lock',
          ),
        ],
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
            return const Center(child: CircularProgressIndicator());
          }

          double? actualDirection = snapshot.data?.heading;

          if (actualDirection == null) {
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
                  ],
                ),
              ),
            );
          }

          if (_isLocked && _lockedHeading == null) {
            _lockedHeading = actualDirection;
          }

          double displayDirection = _isLocked ? _lockedHeading! : actualDirection;
          double turns = displayDirection / 360.0;
          double sunAzimuth = _getSunAzimuth();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${displayDirection.toStringAsFixed(1)}°',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isLocked ? theme.colorScheme.primary : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getDirection(displayDirection),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _isLocked ? theme.colorScheme.primary : theme.colorScheme.secondary,
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
                          for (double i = 0; i < 360; i += 22.5)
                            if (i % 45 != 0) _buildTickMark(i, theme)
                        ],
                      ),
                    ),

                    // Sun Tracker Indicator
                    Positioned.fill(
                      child: AnimatedRotation(
                        turns: (sunAzimuth - displayDirection) / 360.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 24),
                            child: const Icon(Icons.wb_sunny, color: Colors.orange, size: 24),
                          ),
                        ),
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
                        color: theme.colorScheme.onSurface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              if (_isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Direction Locked',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
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
                color: isNorth ? Colors.red : (isPrimary ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6)),
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
            color: theme.colorScheme.onSurface.withOpacity(0.3),
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
