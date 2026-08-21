import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorLabScreen extends StatefulWidget {
  const SensorLabScreen({super.key});

  @override
  State<SensorLabScreen> createState() => _SensorLabScreenState();
}

class _SensorLabScreenState extends State<SensorLabScreen> {
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEventStream().listen((AccelerometerEvent event) {
        setState(() {
          _accelerometerValues = <double>[event.x, event.y, event.z];
        });
      }, onError: (e) {
        // Fallback or ignore
      }),
    );
    _streamSubscriptions.add(
      gyroscopeEventStream().listen((GyroscopeEvent event) {
        setState(() {
          _gyroscopeValues = <double>[event.x, event.y, event.z];
        });
      }, onError: (e) {}),
    );
    _streamSubscriptions.add(
      magnetometerEventStream().listen((MagnetometerEvent event) {
        setState(() {
          _magnetometerValues = <double>[event.x, event.y, event.z];
        });
      }, onError: (e) {}),
    );
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Lab'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Raw Hardware Data',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 16),
          _buildSensorCard(
            'Accelerometer (m/s²)',
            _accelerometerValues,
            theme,
            Icons.speed,
          ),
          const SizedBox(height: 16),
          _buildSensorCard(
            'Gyroscope (rad/s)',
            _gyroscopeValues,
            theme,
            Icons.threed_rotation,
          ),
          const SizedBox(height: 16),
          _buildSensorCard(
            'Magnetometer (μT)',
            _magnetometerValues,
            theme,
            Icons.explore,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String title, List<double>? values, ThemeData theme, IconData icon) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (values == null)
              Text(
                'Not available on this device.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAxisValue('X', values[0], theme),
                  _buildAxisValue('Y', values[1], theme),
                  _buildAxisValue('Z', values[2], theme),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisValue(String axis, double value, ThemeData theme) {
    return Column(
      children: [
        Text(
          axis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
          child: Text(
            value.toStringAsFixed(2),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
