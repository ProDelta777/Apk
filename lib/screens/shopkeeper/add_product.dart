import 'package:flutter/material.dart';

// Placeholder for an AI Service that converts voice to text
class AIService {
  Future<String> convertVoiceToText(String audioFilePath) async {
    // In a real implementation, this would upload the file to OpenAI Whisper
    // or Google Cloud Speech-to-Text and return the parsed description.
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    return "2 kg premium basmati rice, packed today.";
  }
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final AIService _aiService = AIService();

  bool _isRecording = false;
  bool _isProcessingVoice = false;

  void _toggleRecording() async {
    if (_isRecording) {
      // Stop recording and process
      setState(() {
        _isRecording = false;
        _isProcessingVoice = true;
      });

      // Simulate sending file to AI
      String fakeAudioPath = "/path/to/recorded/audio.m4a";
      String transcribedText = await _aiService.convertVoiceToText(fakeAudioPath);

      setState(() {
        _descController.text = transcribedText;
        _isProcessingVoice = false;
      });
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _saveProduct() {
    // Logic to save the product to Supabase via SupabaseService
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product Added Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Photo Upload Placeholder
            Container(
              height: 150,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 16),

            // Description with Voice Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                ),
                IconButton(
                  icon: _isProcessingVoice
                      ? const CircularProgressIndicator()
                      : Icon(
                          _isRecording ? Icons.stop_circle : Icons.mic,
                          color: _isRecording ? Colors.red : Colors.blue,
                          size: 32,
                        ),
                  onPressed: _isProcessingVoice ? null : _toggleRecording,
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price (₹)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveProduct,
              child: const Text('Publish Product'),
            ),
          ],
        ),
      ),
    );
  }
}
