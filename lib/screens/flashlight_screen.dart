import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({Key? key}) : super(key: key);

  @override
  _FlashlightScreenState createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool _isTorchOn = false;

  @override
  void dispose() {
    _disableTorch();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    try {
      bool isTorchAvailable = await TorchLight.isTorchAvailable();
      if (isTorchAvailable) {
        if (_isTorchOn) {
          await TorchLight.disableTorch();
          setState(() {
            _isTorchOn = false;
          });
        } else {
          await TorchLight.enableTorch();
          setState(() {
            _isTorchOn = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not toggle torch')),
        );
      }
    }
  }

  Future<void> _disableTorch() async {
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Torch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
              size: 150,
              color: _isTorchOn ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _toggleTorch,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTorchOn ? Colors.amber : Colors.grey[800],
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                _isTorchOn ? 'TURN OFF' : 'TURN ON',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
