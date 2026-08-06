import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class CompassScreen extends StatefulWidget {
  const CompassScreen({Key? key}) : super(key: key);

  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Compass')),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error reading heading: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          double? direction = snapshot.data?.heading;

          if (direction == null) {
            return const Center(child: Text("Device does not have sensors !"));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${direction.toInt()}°',
                  style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 50),
                Transform.rotate(
                  angle: (direction * (math.pi / 180) * -1),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                      ),
                      const Positioned(top: 10, child: Text('N', style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold))),
                      const Positioned(bottom: 10, child: Text('S', style: TextStyle(color: Colors.white, fontSize: 24))),
                      const Positioned(right: 10, child: Text('E', style: TextStyle(color: Colors.white, fontSize: 24))),
                      const Positioned(left: 10, child: Text('W', style: TextStyle(color: Colors.white, fontSize: 24))),
                      Icon(Icons.navigation, size: 100, color: Colors.green.withAlpha(200)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
