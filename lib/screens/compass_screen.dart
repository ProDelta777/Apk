import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  bool _isLocked = false;
  double? _lockedHeading;

  String _getDirection(double? heading) {
    if (heading == null) return '--';
    double h = heading % 360;
    if (h < 0) h += 360;
    final val = ((h / 22.5) + 0.5).floor() % 16;
    final directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
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
        actions: [
          IconButton(
            icon: Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
              color: _isLocked ? theme.colorScheme.primary : null,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
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
            return Center(child: Text('Sensor Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
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
                    Text('Compass Unavailable', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Your device lacks a magnetometer/rotation sensor.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_isLocked && _lockedHeading == null) {
            _lockedHeading = actualDirection;
          }

          double turns = actualDirection / 360.0;

          double deviation = 0;
          if (_isLocked) {
            deviation = actualDirection - _lockedHeading!;
            if (deviation > 180) deviation -= 360;
            if (deviation < -180) deviation += 360;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${actualDirection.toStringAsFixed(1)}°',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isLocked ? theme.colorScheme.primary : null,
                ),
              ),
              Text(
                _getDirection(actualDirection),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _isLocked ? theme.colorScheme.primary : theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              if (_isLocked) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: deviation.abs() < 5 ? Colors.green.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: deviation.abs() < 5 ? Colors.green : Colors.redAccent,
                    )
                  ),
                  child: Text(
                    'LOCKED: ${_lockedHeading!.toStringAsFixed(1)}°  |  DEV: ${deviation > 0 ? '+' : ''}${deviation.toStringAsFixed(1)}°',
                    style: TextStyle(
                      color: deviation.abs() < 5 ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 4),
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

                    AnimatedRotation(
                      turns: -turns,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linearToEaseOut,
                      child: CustomPaint(
                        size: const Size(20, 240),
                        painter: _CompassNeedlePainter(theme.colorScheme.primary),
                      ),
                    ),

                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.surface, width: 4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              if (snapshot.data?.accuracy != null && snapshot.data!.accuracy! == 1)
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
            padding: EdgeInsets.only(top: isPrimary ? 8.0 : 16.0),
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                fontSize: isPrimary ? 20 : 12,
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
            height: 12,
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

    final pathN = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height / 2)
      ..close();

    paint.color = Colors.red;
    canvas.drawPath(pathN, paint);

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
