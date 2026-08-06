import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking & Patrol')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TrackingCard(title: 'Footprints', desc: 'Look for disturbances in soil, bent grass, or crushed leaves. Deeper toe prints indicate running.'),
          TrackingCard(title: 'Vegetation', desc: 'Broken twigs, overturned leaves (showing lighter underside), and bruised foliage indicate recent passage.'),
          TrackingCard(title: 'Concealment', desc: 'Use natural shadows, avoid silhouetting against the sky, and move slowly to avoid detection.'),
          TrackingCard(title: 'Night Movement', desc: 'Rely on peripheral vision. Move during ambient noise (wind, aircraft) to mask footsteps.'),
        ],
      ),
    );
  }
}

class TrackingCard extends StatelessWidget {
  final String title;
  final String desc;

  const TrackingCard({Key? key, required this.title, required this.desc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.green.withAlpha(50)), borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
