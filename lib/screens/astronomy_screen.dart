import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AstronomyScreen extends StatefulWidget {
  const AstronomyScreen({super.key});

  @override
  State<AstronomyScreen> createState() => _AstronomyScreenState();
}

class _AstronomyScreenState extends State<AstronomyScreen> {
  Position? _currentPosition;
  double _sunAzimuth = 180.0;
  String _moonPhase = "Unknown";
  String _sunRise = "--:--";
  String _sunSet = "--:--";
  bool _isLoading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchAstronomicalData();
  }

  Future<void> _fetchAstronomicalData() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _permissionDenied = true;
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
            _permissionDenied = true;
            _isLoading = false;
          });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      _currentPosition = position;
      _calculateSunAndMoon(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateSunAndMoon(double lat, double lon) {
    final now = DateTime.now().toUtc();

    // Moon Phase Approximation (Conway)
    int year = now.year;
    int month = now.month;
    int day = now.day;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    double r = year % 100.0;
    r %= 19;
    if (r > 9) r -= 19;
    r = ((r * 11) % 30) + month + day;
    if (month < 3) r += 2;
    r -= (year < 2000) ? 4 : 8.3;
    r = r.floor() % 30 + (r < 0 ? 30 : 0);

    if (r < 1.84566) _moonPhase = "New Moon";
    else if (r < 5.53699) _moonPhase = "Waxing Crescent";
    else if (r < 9.22831) _moonPhase = "First Quarter";
    else if (r < 12.91963) _moonPhase = "Waxing Gibbous";
    else if (r < 16.61096) _moonPhase = "Full Moon";
    else if (r < 20.30228) _moonPhase = "Waning Gibbous";
    else if (r < 23.99361) _moonPhase = "Last Quarter";
    else if (r < 27.68493) _moonPhase = "Waning Crescent";
    else _moonPhase = "New Moon";

    // Sun Azimuth Approximation
    double timeOffset = lon / 15.0;
    double localSolarTime = now.hour + (now.minute / 60.0) + timeOffset;
    localSolarTime = localSolarTime % 24;

    double azimuth = 180 + ((localSolarTime - 12) * 15.0);
    _sunAzimuth = azimuth % 360;
    if (_sunAzimuth < 0) _sunAzimuth += 360;

    // Rough Sunrise/Sunset estimation (Time offset)
    double hourAngle = 90.0 / 15.0;
    double riseUTC = 12 - hourAngle - timeOffset;
    double setUTC = 12 + hourAngle - timeOffset;

    DateTime riseLocal = DateTime.utc(now.year, now.month, now.day, riseUTC.floor(), ((riseUTC % 1) * 60).floor()).toLocal();
    DateTime setLocal = DateTime.utc(now.year, now.month, now.day, setUTC.floor(), ((setUTC % 1) * 60).floor()).toLocal();

    _sunRise = "${riseLocal.hour.toString().padLeft(2,'0')}:${riseLocal.minute.toString().padLeft(2,'0')}";
    _sunSet = "${setLocal.hour.toString().padLeft(2,'0')}:${setLocal.minute.toString().padLeft(2,'0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sun & Sky'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _permissionDenied
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Location Required', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Astronomical calculations require GPS coordinates to determine true solar positioning.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildAstroCard('Sun Azimuth', '${_sunAzimuth.toStringAsFixed(1)}°', Icons.wb_sunny, theme),
                const SizedBox(height: 16),
                _buildAstroCard('Sunrise', _sunRise, Icons.wb_twilight, theme),
                const SizedBox(height: 16),
                _buildAstroCard('Sunset', _sunSet, Icons.nights_stay, theme),
                const SizedBox(height: 16),
                _buildAstroCard('Moon Phase', _moonPhase, Icons.nightlight_round, theme),
                const SizedBox(height: 32),
                Text(
                  'Calculations are performed offline mathematically based on device coordinates and UTC time.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                )
              ],
          ),
    );
  }

  Widget _buildAstroCard(String title, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: theme.colorScheme.primary),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
