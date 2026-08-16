import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _position;
  String _status = 'Initializing...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking permissions...';
    });

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _status = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _status = 'Location permissions are denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _status = 'Location permissions are permanently denied, we cannot request permissions.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _status = 'Acquiring satellite lock...';
      });

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _position = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error fetching location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_position == null) return;
    final text = 'Lat: ${_position!.latitude}\nLng: ${_position!.longitude}';
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordinates copied to clipboard')),
      );
    });
  }

  void _shareLocation() {
    if (_position == null) return;
    final text = 'My Location:\nLatitude: ${_position!.latitude}\nLongitude: ${_position!.longitude}\nhttps://maps.google.com/?q=${_position!.latitude},${_position!.longitude}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Location'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchLocation,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_status),
                ],
              ),
            )
          : _position == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 64, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          'Location Unavailable',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _status,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Geolocator.openAppSettings(),
                          child: const Text('Open Settings'),
                        )
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.satellite_alt, size: 48, color: Colors.blue),
                            const SizedBox(height: 16),
                            Text(
                              'GPS Lock Active',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDataTile('Latitude', _position!.latitude.toStringAsFixed(6), theme),
                      const SizedBox(height: 8),
                      _buildDataTile('Longitude', _position!.longitude.toStringAsFixed(6), theme),
                      const SizedBox(height: 8),
                      _buildDataTile('Accuracy', '${_position!.accuracy.toStringAsFixed(1)} meters', theme),
                      const SizedBox(height: 8),
                      _buildDataTile('Altitude', '${_position!.altitude.toStringAsFixed(1)} meters', theme),
                      const SizedBox(height: 8),
                      _buildDataTile('Heading', '${_position!.heading.toStringAsFixed(1)}°', theme),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Coordinates'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _shareLocation,
                        icon: const Icon(Icons.share),
                        label: const Text('Share Location Text'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDataTile(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
