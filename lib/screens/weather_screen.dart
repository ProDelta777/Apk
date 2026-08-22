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
  int _refreshIntervalMin = 30; // Default 30 min

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
          if (DateTime.now().difference(lastTime).inMinutes < _refreshIntervalMin) {
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
            _errorMessage = 'Location permission is required for accurate local weather forecasting.';
            _isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

      // Using Open-Meteo for free, no-API-key reliable weather data
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,wind_speed_10m,wind_direction_10m'
        '&hourly=temperature_2m,precipitation_probability,precipitation,weather_code,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum'
        '&timezone=auto'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

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

      // Try to load cache if API failed
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
          _errorMessage = 'Unable to fetch weather and no offline data available. Please check your internet connection.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // WMO Weather interpretation codes
  String _getWeatherDesc(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1: case 2: case 3: return 'Partly cloudy';
      case 45: case 48: return 'Fog';
      case 51: case 53: case 55: return 'Drizzle';
      case 61: case 63: case 65: return 'Rain';
      case 71: case 73: case 75: return 'Snow';
      case 80: case 81: case 82: return 'Rain showers';
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
        appBar: AppBar(title: const Text('Weather & Monsoon')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weather & Monsoon')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(_errorMessage, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _loadWeather(force: true),
                  child: const Text('RETRY'),
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

    // Monsoon/Rain Alert Logic
    final maxRainProb = (daily['precipitation_probability_max'] as List).first as int;
    final totalRain = (daily['precipitation_sum'] as List).first as double;

    String alertMsg = "No significant rain expected.";
    Color alertColor = Colors.green;
    IconData alertIcon = Icons.wb_sunny_outlined;

    if (maxRainProb > 70 || totalRain > 10.0) {
      alertMsg = "Heavy Rain / Monsoon Warning";
      alertColor = Colors.redAccent;
      alertIcon = Icons.warning;
    } else if (maxRainProb > 40) {
      alertMsg = "Rain Likely";
      alertColor = Colors.orange;
      alertIcon = Icons.umbrella;
    } else if (maxRainProb > 10) {
      alertMsg = "Possible Light Rain";
      alertColor = Colors.blueAccent;
      alertIcon = Icons.water_drop;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather & Monsoon'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadWeather(force: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadWeather(force: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Header
            if (_isOffline)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text('OFFLINE (Showing cached data)', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),

            Text(
              'Last updated: ${_lastUpdated?.hour.toString().padLeft(2, '0')}:${_lastUpdated?.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Main Current Weather Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(_getWeatherIcon(current['weather_code']), size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('${current['temperature_2m']}°C', style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(_getWeatherDesc(current['weather_code']), style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSmallStat('Feels Like', '${current['apparent_temperature']}°C', theme),
                        _buildSmallStat('Humidity', '${current['relative_humidity_2m']}%', theme),
                        _buildSmallStat('Wind', '${current['wind_speed_10m']} km/h', theme),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rain/Monsoon Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: alertColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: alertColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(alertIcon, color: alertColor, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MONSOON / RAIN ALERT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: alertColor)),
                        const SizedBox(height: 4),
                        Text(alertMsg, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Max Prob: $maxRainProb%  |  Amount: ${totalRain}mm', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 7-Day Forecast
            Text('7-Day Forecast', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(7, (index) {
              final dateStr = daily['time'][index];
              final date = DateTime.parse(dateStr);
              final dayName = _getDayName(date.weekday);
              final maxT = daily['temperature_2m_max'][index];
              final minT = daily['temperature_2m_min'][index];
              final code = daily['weather_code'][index];
              final pop = daily['precipitation_probability_max'][index];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(_getWeatherIcon(code), color: theme.colorScheme.primary),
                  title: Text(index == 0 ? 'Today' : dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rain: $pop%'),
                  trailing: Text('$minT°  /  $maxT°', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Extended Weather Outlook is derived from global meteorological models. Exact monthly forecasts are not scientifically reliable.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 10),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}
