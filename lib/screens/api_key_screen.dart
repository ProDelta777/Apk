import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyScreen extends StatefulWidget {
  final VoidKeyCallback onKeySaved;

  const ApiKeyScreen({super.key, required this.onKeySaved});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

typedef VoidKeyCallback = void Function(String apiKey);

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _keyController = TextEditingController();

  Future<void> _saveKey() async {
    if (_keyController.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _keyController.text.trim());

    widget.onKeySaved(_keyController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup AI Assistant'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.vpn_key, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              'Enter your Gemini API Key to unlock the Smart AI Assistant.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveKey,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Key', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
