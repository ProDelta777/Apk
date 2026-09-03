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

  // 0: Off, 1: On (Steady), 2: SOS, 3: Strobe, 4: Custom Morse
  int _currentMode = 0;
  Timer? _strobeTimer;
  bool _strobeState = false;

  final TextEditingController _morseController = TextEditingController();
  bool _isMorsePlaying = false;

  // Standard International Morse Code dictionary
  final Map<String, String> _morseDict = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
    '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...',
    '8': '---..', '9': '----.'
  };

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

    _strobeTimer?.cancel();
    _isMorsePlaying = false;

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
      } else if (mode == 4) {
        _runMorseMode();
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

  Future<void> _flash(int durationMs, int modeNumber) async {
    if (_currentMode != modeNumber) return;
    try { await TorchLight.enableTorch(); } catch (_) {}
    await Future.delayed(Duration(milliseconds: durationMs));

    if (_currentMode != modeNumber) return;
    try { await TorchLight.disableTorch(); } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _runSOSMode() async {
    while (_currentMode == 2) {
      for (int i=0; i<3; i++) { await _flash(200, 2); if (_currentMode != 2) return; }
      await Future.delayed(const Duration(milliseconds: 400));
      for (int i=0; i<3; i++) { await _flash(600, 2); if (_currentMode != 2) return; }
      await Future.delayed(const Duration(milliseconds: 400));
      for (int i=0; i<3; i++) { await _flash(200, 2); if (_currentMode != 2) return; }
      await Future.delayed(const Duration(milliseconds: 1400));
    }
  }

  void _runMorseMode() async {
    final text = _morseController.text.toUpperCase();
    if (text.isEmpty) {
      _setMode(0);
      return;
    }

    setState(() { _isMorsePlaying = true; });

    for (int i = 0; i < text.length; i++) {
      if (_currentMode != 4) break;
      final char = text[i];

      if (char == ' ') {
        await Future.delayed(const Duration(milliseconds: 1400)); // Word gap
        continue;
      }

      final morseCode = _morseDict[char];
      if (morseCode != null) {
        for (int j = 0; j < morseCode.length; j++) {
          if (_currentMode != 4) break;
          final symbol = morseCode[j];
          if (symbol == '.') {
            await _flash(200, 4);
          } else if (symbol == '-') {
            await _flash(600, 4);
          }
        }
        await Future.delayed(const Duration(milliseconds: 600)); // Char gap
      }
    }

    if (mounted) {
      _setMode(0);
      setState(() { _isMorsePlaying = false; });
    }
  }

  @override
  void dispose() {
    _strobeTimer?.cancel();
    _morseController.dispose();
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
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
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

                        const SizedBox(height: 32),

                        // Morse Code Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Morse Code Transmitter',
                                style: TextStyle(
                                  color: isOn ? Colors.black87 : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _morseController,
                                      style: TextStyle(color: isOn ? Colors.black : Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Enter text to transmit...',
                                        hintStyle: TextStyle(color: isOn ? Colors.black54 : Colors.white54),
                                        filled: true,
                                        fillColor: isOn ? Colors.black12 : Colors.white12,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: _isMorsePlaying ? () => _setMode(0) : () => _setMode(4),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isMorsePlaying ? Colors.red : Colors.green,
                                      padding: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Icon(_isMorsePlaying ? Icons.stop : Icons.send, color: Colors.white),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        Text(
                          _currentMode == 1 ? 'STEADY' :
                          _currentMode == 2 ? 'SOS SIGNAL' :
                          _currentMode == 3 ? 'STROBE' :
                          _currentMode == 4 ? 'MORSE CODE' : 'OFF',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isOn ? Colors.black87 : Colors.white54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
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
