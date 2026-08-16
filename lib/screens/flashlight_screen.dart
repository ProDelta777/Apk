import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool _isTorchAvailable = false;
  bool _isChecking = true;

  // 0: Off, 1: On (Steady), 2: SOS, 3: Strobe
  int _currentMode = 0;
  Timer? _strobeTimer;
  bool _strobeState = false;

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

  Future<void> _setMode(int mode) async {
    if (!_isTorchAvailable) return;

    // Clean up any existing timers
    _strobeTimer?.cancel();

    setState(() {
      _currentMode = mode;
    });

    try {
      if (mode == 0) {
        await TorchLight.disableTorch();
      } else if (mode == 1) {
        await TorchLight.enableTorch();
      } else if (mode == 2) {
        _runSOSMode();
      } else if (mode == 3) {
        _runStrobeMode();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not change torch state: $e')),
        );
      }
    }
  }

  void _runStrobeMode() {
    _strobeState = false;
    _strobeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (_currentMode != 3) {
        timer.cancel();
        return;
      }
      try {
        if (_strobeState) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }
        _strobeState = !_strobeState;
      } catch (_) {}
    });
  }

  void _runSOSMode() async {
    // SOS: 3 short, 3 long, 3 short
    // Short = 200ms, Long = 600ms, Gap = 200ms, LetterGap = 600ms, WordGap = 1400ms

    Future<void> flash(int durationMs) async {
      if (_currentMode != 2) return;
      try { await TorchLight.enableTorch(); } catch (_) {}
      await Future.delayed(Duration(milliseconds: durationMs));

      if (_currentMode != 2) return;
      try { await TorchLight.disableTorch(); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200)); // intra-character gap
    }

    while (_currentMode == 2) {
      // S (3 short)
      for (int i=0; i<3; i++) { await flash(200); if (_currentMode != 2) return; }
      await Future.delayed(const Duration(milliseconds: 400)); // remaining gap to 600ms

      // O (3 long)
      for (int i=0; i<3; i++) { await flash(600); if (_currentMode != 2) return; }
      await Future.delayed(const Duration(milliseconds: 400));

      // S (3 short)
      for (int i=0; i<3; i++) { await flash(200); if (_currentMode != 2) return; }

      // End of word gap
      await Future.delayed(const Duration(milliseconds: 1400));
    }
  }

  @override
  void dispose() {
    _strobeTimer?.cancel();
    TorchLight.disableTorch().catchError((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isOn = _currentMode != 0;

    return Scaffold(
      backgroundColor: isOn ? Colors.white : (isDark ? const Color(0xFF121212) : Colors.black87),
      appBar: AppBar(
        title: Text(
          'Tactical Flashlight',
          style: TextStyle(color: isOn ? Colors.black : Colors.white),
        ),
        iconTheme: IconThemeData(color: isOn ? Colors.black : Colors.white),
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
                        onTap: () => _setMode(isOn ? 0 : 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOn ? Colors.yellow.shade400 : Colors.grey.shade900,
                            boxShadow: isOn
                                ? [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.5),
                                      blurRadius: 50,
                                      spreadRadius: 20,
                                    )
                                  ]
                                : [],
                            border: Border.all(
                              color: isOn ? Colors.yellow.shade100 : Colors.grey.shade800,
                              width: 4,
                            ),
                          ),
                          child: Icon(
                            Icons.power_settings_new,
                            size: 80,
                            color: isOn ? Colors.black87 : Colors.white24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Tactical Modes
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isOn ? Colors.black12 : Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildModeButton('STEADY', 1, isOn),
                            _buildModeButton('S.O.S', 2, isOn, isCritical: true),
                            _buildModeButton('STROBE', 3, isOn, isCritical: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                      Text(
                        _currentMode == 1 ? 'STEADY' :
                        _currentMode == 2 ? 'SOS SIGNAL' :
                        _currentMode == 3 ? 'STROBE' : 'OFF',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isOn ? Colors.black87 : Colors.white54,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildModeButton(String text, int mode, bool isOn, {bool isCritical = false}) {
    final isActive = _currentMode == mode;

    return GestureDetector(
      onTap: () => _setMode(isActive ? 0 : mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (isCritical ? Colors.red : Colors.green)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : (isOn ? Colors.black26 : Colors.white24),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (isOn ? Colors.black87 : Colors.white70),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
