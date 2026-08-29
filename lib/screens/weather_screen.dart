import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  bool _isOffline = false;
  String _errorMessage = '';

  Map<String, dynamic>? _weatherData;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadWeather(force: false);
  }

  Future<void> _loadWeather({bool force = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      if (!force) {
        final cachedData = prefs.getString('cached_weather');
        final cachedTime = prefs.getInt('cached_weather_time');

        if (cachedData != null && cachedTime != null) {
          final lastTime = DateTime.fromMillisecondsSinceEpoch(cachedTime);
          if (DateTime.now().difference(lastTime).inMinutes < 30) {
            setState(() {
              _weatherData = jsonDecode(cachedData);
              _lastUpdated = lastTime;
              _isLoading = false;
            });
            return;
          }
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          setState(() {
            _errorMessage = 'Location permission is required for accurate local monsoon tracking and weather forecasting.';
            _isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,wind_speed_10m'
        '&hourly=temperature_2m,precipitation_probability,precipitation,weather_code'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum'
        '&timezone=auto'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        prefs.setString('cached_weather', response.body);
        prefs.setInt('cached_weather_time', DateTime.now().millisecondsSinceEpoch);

        setState(() {
          _weatherData = data;
          _lastUpdated = DateTime.now();
          _isOffline = false;
        });
      } else {
        throw Exception('Failed to fetch weather data.');
      }
    } catch (e) {
      debugPrint('Weather fetch error: $e');

      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_weather');
      final cachedTime = prefs.getInt('cached_weather_time');

      if (cachedData != null && cachedTime != null) {
        setState(() {
          _weatherData = jsonDecode(cachedData);
          _lastUpdated = DateTime.fromMillisecondsSinceEpoch(cachedTime);
          _isOffline = true;
        });
      } else {
        setState(() {
          _errorMessage = 'No internet connection and no offline cached data available. Please reconnect to sync weather.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getWeatherDesc(int code) {
    switch (code) {
      case 0: return 'Clear Sky';
      case 1: case 2: case 3: return 'Partly Cloudy';
      case 45: case 48: return 'Fog';
      case 51: case 53: case 55: return 'Drizzle';
      case 61: case 63: case 65: return 'Rain';
      case 71: case 73: case 75: return 'Snow';
      case 80: case 81: case 82: return 'Rain Showers';
      case 95: case 96: case 99: return 'Thunderstorm';
      default: return 'Unknown';
    }
  }

  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0: return Icons.wb_sunny;
      case 1: case 2: case 3: return Icons.cloud;
      case 45: case 48: return Icons.foggy;
      case 51: case 53: case 55: return Icons.water_drop;
      case 61: case 63: case 65: return Icons.umbrella;
      case 71: case 73: case 75: return Icons.ac_unit;
      case 80: case 81: case 82: return Icons.beach_access;
      case 95: case 96: case 99: return Icons.flash_on;
      default: return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading && _weatherData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Monsoon & Weather')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Monsoon & Weather')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 80, color: theme.colorScheme.error),
                const SizedBox(height: 24),
                Text(_errorMessage, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _loadWeather(force: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('RETRY'),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (_weatherData == null) return const SizedBox();

    final current = _weatherData!['current'];
    final daily = _weatherData!['daily'];

    // Core Monsoon Logic
    final maxRainProb = (daily['precipitation_probability_max'] as List).first as int;
    final totalRain = (daily['precipitation_sum'] as List).first as double;

    String alertTitle = "NO SIGNIFICANT RAIN EXPECTED";
    String alertDesc = "Conditions appear dry. No monsoon activity currently detected in your localized area.";
    Color alertColor = Colors.green;
    IconData alertIcon = Icons.wb_sunny_outlined;

    if (maxRainProb > 70 || totalRain > 15.0) {
      alertTitle = "HEAVY RAIN / MONSOON WARNING";
      alertDesc = "Extreme precipitation expected. Secure your gear and avoid flood zones. High probability of continuous downpour.";
      alertColor = Colors.redAccent;
      alertIcon = Icons.warning;
    } else if (maxRainProb > 40 || totalRain > 5.0) {
      alertTitle = "RAIN LIKELY";
      alertDesc = "Rain is expected in your sector. Prepare rain gear. Precipitation probability is elevated.";
      alertColor = Colors.orange;
      alertIcon = Icons.umbrella;
    } else if (maxRainProb > 10 || totalRain > 1.0) {
      alertTitle = "POSSIBLE LIGHT RAIN";
      alertDesc = "Scattered showers or light drizzle may occur. Keep protective gear accessible.";
      alertColor = Colors.lightBlueAccent;
      alertIcon = Icons.water_drop;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monsoon & Weather'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadWeather(force: true),
            tooltip: 'Sync Forecast',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadWeather(force: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isOffline)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text('OFFLINE MODE — Showing Cached Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            Text(
              'Last synced: ${_lastUpdated?.year}-${_lastUpdated?.month.toString().padLeft(2,'0')}-${_lastUpdated?.day.toString().padLeft(2,'0')} ${_lastUpdated?.hour.toString().padLeft(2, '0')}:${_lastUpdated?.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Giant Monsoon Radar Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: alertColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: alertColor.withOpacity(0.4), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: alertColor.withOpacity(0.2), shape: BoxShape.circle),
                        child: Icon(alertIcon, color: alertColor, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          alertTitle,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: alertColor, letterSpacing: 1),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(alertDesc, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Max Probability', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                          Text('$maxRainProb%', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: alertColor)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Expected Vol.', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                          Text('${totalRain}mm', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: alertColor)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Current Weather
            Text('ATMOSPHERIC CONDITIONS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${current['temperature_2m']}°C', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(_getWeatherDesc(current['weather_code']), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                        const SizedBox(height: 8),
                        Text('Feels like ${current['apparent_temperature']}°C', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                      ],
                    ),
                    Icon(_getWeatherIcon(current['weather_code']), size: 80, color: theme.colorScheme.primary.withOpacity(0.8)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildInfoTile('Humidity', '${current['relative_humidity_2m']}%', Icons.water, theme)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoTile('Wind Speed', '${current['wind_speed_10m']} km/h', Icons.air, theme)),
              ],
            ),
            const SizedBox(height: 32),

            // 7-Day Forecast
            Text('7-DAY OUTLOOK', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            ...List.generate(7, (index) {
              final dateStr = daily['time'][index];
              final date = DateTime.parse(dateStr);
              final dayName = _getDayName(date.weekday);
              final maxT = daily['temperature_2m_max'][index];
              final minT = daily['temperature_2m_min'][index];
              final code = daily['weather_code'][index];
              final pop = daily['precipitation_probability_max'][index];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(index == 0 ? 'Today' : dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Icon(_getWeatherIcon(code), color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Rain: $pop%', style: TextStyle(color: pop > 30 ? Colors.blueAccent : theme.hintColor, fontSize: 12)),
                    ),
                    Text('$minT°', style: TextStyle(color: theme.hintColor)),
                    const SizedBox(width: 8),
                    Container(width: 32, height: 4, decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Text('$maxT°', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(
              'Extended Weather Outlook is derived from global meteorological models. Exact long-range monthly forecasts are not scientifically reliable.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 10),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.hintColor, size: 20),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}
