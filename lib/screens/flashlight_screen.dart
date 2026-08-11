import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool _isTorchOn = false;
  bool _isTorchAvailable = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkTorchAvailability();
  }

  Future<void> _checkTorchAvailability() async {
    try {
      final isAvailable = await TorchLight.isTorchAvailable();
      setState(() {
        _isTorchAvailable = isAvailable;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isTorchAvailable = false;
        _isChecking = false;
      });
    }
  }

  Future<void> _toggleTorch() async {
    if (!_isTorchAvailable) return;

    try {
      if (_isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not change torch state: $e')),
      );
    }
  }

  @override
  void dispose() {
    if (_isTorchOn) {
      TorchLight.disableTorch().catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _isTorchOn ? Colors.white : (isDark ? const Color(0xFF121212) : Colors.black87),
      appBar: AppBar(
        title: Text(
          'Flashlight',
          style: TextStyle(color: _isTorchOn ? Colors.black : Colors.white),
        ),
        iconTheme: IconThemeData(color: _isTorchOn ? Colors.black : Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _isChecking
            ? const CircularProgressIndicator()
            : !_isTorchAvailable
                ? Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flashlight_off, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        Text(
                          'Flashlight Unavailable',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your device does not have a camera flash or it is currently unavailable.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _toggleTorch,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isTorchOn ? Colors.yellow.shade400 : Colors.grey.shade900,
                            boxShadow: _isTorchOn
                                ? [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.5),
                                      blurRadius: 50,
                                      spreadRadius: 20,
                                    )
                                  ]
                                : [],
                            border: Border.all(
                              color: _isTorchOn ? Colors.yellow.shade100 : Colors.grey.shade800,
                              width: 4,
                            ),
                          ),
                          child: Icon(
                            Icons.power_settings_new,
                            size: 80,
                            color: _isTorchOn ? Colors.black87 : Colors.white24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        _isTorchOn ? 'ON' : 'OFF',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: _isTorchOn ? Colors.black87 : Colors.white54,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
