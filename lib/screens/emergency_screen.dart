import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  Position? _position;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoading = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _isLoading = false);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          setState(() => _isLoading = false);
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _shareLocation() {
    if (_position != null) {
      Share.share('EMERGENCY LOCATION\nLat: ${_position!.latitude}\nLng: ${_position!.longitude}\nAccuracy: ${_position!.accuracy}m\nTime: ${DateTime.now().toIso8601String()}');
    }
  }

  void _copyLocation() {
    if (_position != null) {
      Clipboard.setData(ClipboardData(text: 'Lat: ${_position!.latitude}, Lng: ${_position!.longitude}'));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Text(
                    'MY CURRENT LOCATION',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.red)
                  else if (_position == null)
                    const Text('Location Unavailable', style: TextStyle(color: Colors.red))
                  else
                    Column(
                      children: [
                        Text('Latitude: ${_position!.latitude}', style: theme.textTheme.titleMedium),
                        Text('Longitude: ${_position!.longitude}', style: theme.textTheme.titleMedium),
                        Text('Accuracy: ±${_position!.accuracy.toStringAsFixed(1)}m', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _position == null ? null : _copyLocation,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _position == null ? null : _shareLocation,
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildChecklist(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(ThemeData theme) {
    final items = [
      'Assess the situation and ensure immediate safety.',
      'Check for injuries and apply basic first aid if trained.',
      'Find shelter if exposed to extreme weather.',
      'Conserve device battery: lower brightness, turn off unnecessary radios.',
      'Stay put if you are lost; do not wander further.',
      'Use the flashlight SOS tool (3 short, 3 long, 3 short) if visible to rescuers.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Checklist',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
