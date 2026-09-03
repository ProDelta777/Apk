import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class AstronomyScreen extends StatefulWidget {
  const AstronomyScreen({super.key});

  @override
  State<AstronomyScreen> createState() => _AstronomyScreenState();
}

class _AstronomyScreenState extends State<AstronomyScreen> {
  bool _isLoading = true;
  String _error = '';

  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Simplified Conway's Moon Phase calculation
  String _getMoonPhase(DateTime date) {
    int r = date.year % 100;
    r %= 19;
    if (r > 9) { r -= 19; }
    r = ((r * 11) % 30) + date.month + date.day;
    if (date.month < 3) { r += 2; }
    r -= ((date.year < 2000) ? 4 : 8.3).toInt();
    r = (r + 0.5).floor() % 30;

    if (r < 0) { r += 30; }

    if (r == 0) return 'New Moon';
    if (r > 0 && r < 7) return 'Waxing Crescent';
    if (r == 7) return 'First Quarter';
    if (r > 7 && r < 15) return 'Waxing Gibbous';
    if (r == 15) return 'Full Moon';
    if (r > 15 && r < 22) return 'Waning Gibbous';
    if (r == 22) return 'Last Quarter';
    return 'Waning Crescent';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Astronomy & Sun Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_disabled, size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text('Location Required', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(_error, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() { _isLoading = true; _error = ''; });
                        _getLocation();
                      },
                      child: const Text('Retry'),
                    )
                  ],
                ),
              )
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCard(
                  theme: theme,
                  icon: Icons.brightness_3,
                  title: 'Moon Phase',
                  value: _getMoonPhase(DateTime.now()),
                  subtitle: 'Calculated locally via Conway\'s algorithm',
                ),
                const SizedBox(height: 16),
                _buildCard(
                  theme: theme,
                  icon: Icons.wb_sunny,
                  title: 'Sun Azimuth',
                  value: 'Not implemented (offline calculation complex)',
                  subtitle: 'Lat: ${_latitude?.toStringAsFixed(4)}, Lon: ${_longitude?.toStringAsFixed(4)}',
                ),
                const SizedBox(height: 16),
                _buildCard(
                  theme: theme,
                  icon: Icons.wb_twilight,
                  title: 'Sunrise / Sunset',
                  value: 'Not implemented (offline calculation complex)',
                  subtitle: 'Based on current coordinates',
                ),
              ],
          ),
    );
  }

  Widget _buildCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          )
        ],
      ),
    );
  }
}
