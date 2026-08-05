import "package:pro_army/screens/notes_screen.dart";
import "package:pro_army/screens/weapons_info_screen.dart";
import "package:pro_army/screens/tracking_screen.dart";
import "package:pro_army/screens/sos_screen.dart";
import "package:pro_army/screens/flashlight_screen.dart";
import "package:pro_army/screens/compass_screen.dart";
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide DateFormat;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _timeString = "";
  String _dateString = "";
  Timer? _timer;

  Position? _currentPosition;
  String _gpsStatus = "OFF";

  final List<Map<String, dynamic>> _modules = [
    {'title': 'Smart Compass', 'icon': Icons.explore},
    {'title': 'Military Maps', 'icon': Icons.map},
    {'title': 'Patrol', 'icon': Icons.security},
    {'title': 'Reconnaissance', 'icon': Icons.visibility},
    {'title': 'Drill', 'icon': Icons.accessibility_new},
    {'title': 'Field Craft', 'icon': Icons.nature_people},
    {'title': 'Navigation', 'icon': Icons.navigation},
    {'title': 'First Aid', 'icon': Icons.medical_services},
    {'title': 'Weather', 'icon': Icons.cloud},
    {'title': 'Survival', 'icon': Icons.fireplace},
    {'title': 'Morse Code', 'icon': Icons.more_horiz},
    {'title': 'NATO Alphabet', 'icon': Icons.sort_by_alpha},
    {'title': 'Knots', 'icon': Icons.gesture},
    {'title': 'Weapons Info', 'icon': Icons.shield},
    {'title': 'Field ID Guide', 'icon': Icons.book},
    {'title': 'Camp Assistant', 'icon': Icons.campaign},
    {'title': 'Medical Card', 'icon': Icons.contact_page},
    {'title': 'SOS', 'icon': Icons.sos},
    {'title': 'Flashlight', 'icon': Icons.flashlight_on},
    {'title': 'Notes', 'icon': Icons.note},
    {'title': 'Downloads', 'icon': Icons.download},
    {'title': 'Training Timer', 'icon': Icons.timer},
    {'title': 'More Tools', 'icon': Icons.construction},
    {'title': 'Settings', 'icon': Icons.settings},
  ];

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _dateString = _formatDate(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = _formatDateTime(now);
    final String formattedDate = _formatDate(now);
    if (mounted) {
      setState(() {
        _timeString = formattedTime;
        _dateString = formattedDate;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('EEE, MMM dd, yyyy').format(dateTime);
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _gpsStatus = "OFF"; });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _gpsStatus = "DENIED"; });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() { _gpsStatus = "DENIED"; });
      return;
    }

    setState(() { _gpsStatus = "ON"; });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
     try {
       Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
       setState(() {
         _currentPosition = position;
       });
     } catch (e) {
       print("Error getting location: $e");
     }
  }

  Widget _buildStatusPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: Colors.green.withAlpha(128)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('dashboard.field_assistant'.tr(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text('${'dashboard.gps'.tr()} $_gpsStatus | ${'dashboard.mag'.tr()} N/A', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_timeString, style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_dateString, style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              )
            ],
          ),
          const Divider(color: Colors.green),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('dashboard.lat'.tr(), _currentPosition != null ? _currentPosition!.latitude.toStringAsFixed(4) : '—'),
              _buildStat('dashboard.lon'.tr(), _currentPosition != null ? _currentPosition!.longitude.toStringAsFixed(4) : '—'),
              _buildStat('dashboard.alt'.tr(), _currentPosition != null ? '${_currentPosition!.altitude.toStringAsFixed(0)}m' : '—'),
              _buildStat('dashboard.spd'.tr(), _currentPosition != null ? '${(_currentPosition!.speed * 3.6).toStringAsFixed(1)} km/h' : '0.0 km/h'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildStat('dashboard.grid'.tr(), '—'),
               _buildStat('dashboard.acc'.tr(), _currentPosition != null ? '${_currentPosition!.accuracy.toStringAsFixed(1)}m' : '—'),
               _buildStat('dashboard.mode'.tr(), 'dashboard.offline'.tr(), color: Colors.amber),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.green, fontSize: 10)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.sos, 'dashboard.sos'.tr(), Colors.red, () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SosScreen())); }),
        _buildActionButton(Icons.flashlight_on, 'dashboard.torch'.tr(), Colors.amber, () { Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashlightScreen())); }),
        _buildActionButton(Icons.explore, 'dashboard.compass'.tr(), Colors.blue, () { Navigator.push(context, MaterialPageRoute(builder: (context) => const CompassScreen())); }),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(51),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.language), onPressed: () { if (context.locale.languageCode == "en") { context.setLocale(const Locale("hi", "IN")); } else { context.setLocale(const Locale("en", "US")); } }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusPanel(),
            _buildQuickActions(),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('dashboard.command_modules'.tr(), style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _modules.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green.withAlpha(76), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () { if (_modules[index]['title'] == 'Weapons Info') { Navigator.push(context, MaterialPageRoute(builder: (context) => const WeaponsInfoScreen())); } else if (_modules[index]['title'] == 'Patrol') { Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackingScreen())); } else if (_modules[index]['title'] == 'Notes') { Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen())); } else if (_modules[index]['title'] == 'Flashlight') { Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashlightScreen())); } else if (_modules[index]['title'] == 'SOS') { Navigator.push(context, MaterialPageRoute(builder: (context) => const SosScreen())); } else if (_modules[index]['title'] == 'Smart Compass') { Navigator.push(context, MaterialPageRoute(builder: (context) => const CompassScreen())); } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_modules[index]['title']} module is offline.'))); } },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_modules[index]['icon'], color: Colors.green, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            _modules[index]['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green.withAlpha(25),
              child: Text(
                'dashboard.system_status'.tr(),
                style: TextStyle(color: Colors.green, fontSize: 10, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
