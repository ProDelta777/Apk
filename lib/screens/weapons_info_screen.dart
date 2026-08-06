import 'package:flutter/material.dart';

class WeaponsInfoScreen extends StatelessWidget {
  const WeaponsInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weapons Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          WeaponCard(name: 'INSAS Rifle', origin: 'India', type: 'Assault Rifle', caliber: '5.56×45mm NATO', desc: 'Standard infantry weapon of the Indian Armed Forces.'),
          WeaponCard(name: 'AK-203', origin: 'Russia/India', type: 'Assault Rifle', caliber: '7.62×39mm', desc: 'Modernized version of the AK-47 series, currently replacing the INSAS.'),
          WeaponCard(name: 'SIG Sauer 716', origin: 'USA/Switzerland', type: 'Battle Rifle', caliber: '7.62×51mm NATO', desc: 'Used by frontline troops for higher range and lethality.'),
          WeaponCard(name: 'Dragunov SVD', origin: 'Soviet Union', type: 'Sniper Rifle', caliber: '7.62×54mmR', desc: 'Standard designated marksman rifle of the Indian Army.'),
        ],
      ),
    );
  }
}

class WeaponCard extends StatelessWidget {
  final String name;
  final String origin;
  final String type;
  final String caliber;
  final String desc;

  const WeaponCard({Key? key, required this.name, required this.origin, required this.type, required this.caliber, required this.desc}) : super(key: key);

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
            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(color: Colors.green),
            Text('Type: $type', style: const TextStyle(color: Colors.white70)),
            Text('Caliber: $caliber', style: const TextStyle(color: Colors.white70)),
            Text('Origin: $origin', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
