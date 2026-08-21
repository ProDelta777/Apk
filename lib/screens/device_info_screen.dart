import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool _isLoading = true;

  static const batteryChannel = MethodChannel('com.offgrid.utility/battery');
  double? _batteryTemp;
  String _batteryStatus = "UNKNOWN";

  @override
  void initState() {
    super.initState();
    _initDeviceData();
    _fetchBatteryData();
  }

  Future<void> _fetchBatteryData() async {
    try {
      final double result = await batteryChannel.invokeMethod('getBatteryTemperature');
      setState(() {
        _batteryTemp = result;
        if (result < 35.0) {
          _batteryStatus = "NORMAL";
        } else if (result < 40.0) {
          _batteryStatus = "WARM";
        } else {
          _batteryStatus = "HIGH";
        }
      });
    } on PlatformException catch (e) {
      setState(() {
        _batteryTemp = null;
        _batteryStatus = "UNAVAILABLE";
      });
      debugPrint("Failed to get battery temp: '${e.message}'.");
    }
  }

  Future<void> _initDeviceData() async {
    try {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      setState(() {
        _deviceData = {
          'Brand': androidInfo.brand,
          'Device': androidInfo.device,
          'Model': androidInfo.model,
          'Manufacturer': androidInfo.manufacturer,
          'Product': androidInfo.product,
          'Hardware': androidInfo.hardware,
          'Android Version': androidInfo.version.release,
          'SDK Version': androidInfo.version.sdkInt.toString(),
          'Security Patch': androidInfo.version.securityPatch ?? 'Unknown',
          'Supported ABIs': androidInfo.supportedAbis.join(', '),
          'Display': androidInfo.display,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _deviceData = {'Error': 'Failed to get device info: $e'};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBatterySection(theme),
                const SizedBox(height: 24),
                ..._deviceData.keys.map((String property) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      title: Text(
                        property,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${_deviceData[property]}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildBatterySection(ThemeData theme) {
    Color statusColor = Colors.grey;
    if (_batteryStatus == "NORMAL") statusColor = Colors.green;
    if (_batteryStatus == "WARM") statusColor = Colors.orange;
    if (_batteryStatus == "HIGH") statusColor = Colors.red;

    return Card(
      elevation: 0,
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.battery_charging_full, color: statusColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Battery Thermal Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _batteryTemp != null ? '${_batteryTemp!.toStringAsFixed(1)} °C' : '-- °C',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _batteryStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_batteryTemp == null) ...[
              const SizedBox(height: 12),
              Text(
                'Temperature information is not available on this device.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              )
            ]
          ],
        ),
      ),
    );
  }
}
