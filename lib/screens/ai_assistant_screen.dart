import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bill_item.dart';
import 'package:share_plus/share_plus.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the mic and tell me what you sold... \n(e.g. "5 kg aloo at 200 per kg and 2 kg karela at 100")';
  bool _isLoading = false;

  List<BillItem> _generatedItems = [];
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  // Retrieving the API key injected securely at compile-time
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            if (_text.isNotEmpty && _text != 'Press the mic and tell me what you sold... \n(e.g. "5 kg aloo at 200 per kg and 2 kg karela at 100")') {
              _processVoiceWithAI(_text);
            }
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _generatedItems = [];
          _text = '';
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _processVoiceWithAI(String prompt) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_apiKey.isEmpty) {
        throw Exception("API Key not found in build environment.");
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system('''
You are an expert billing assistant for an Indian shopkeeper. The user will speak a sentence containing items they sold, their quantities, and their rates.
Extract the items, rates, and quantities.
If a rate is given as a total (e.g. 5kg aloo for 200 total), calculate the per unit rate.
Return ONLY a valid JSON array where each object has "name" (String), "rate" (number), and "quantity" (number).
Do not return any markdown formatting, just the raw JSON array.
For example, if input is "5 kg aloo 200 aur 2 kg karela 100 ke hisab se", return:
[{"name": "Aloo", "rate": 40, "quantity": 5}, {"name": "Karela", "rate": 100, "quantity": 2}]
'''),
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text?.trim() ?? "[]";

      // Clean up potential markdown formatting from Gemini
      String cleanJson = responseText;
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final List<dynamic> jsonList = jsonDecode(cleanJson);

      setState(() {
        _generatedItems = jsonList.map((item) => BillItem(
          name: item['name'].toString(),
          rate: (item['rate'] as num).toDouble(),
          quantity: (item['quantity'] as num).toDouble(),
        )).toList();
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process. Please try speaking clearly again. Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double get _totalBill => _generatedItems.fold(0, (sum, item) => sum + item.total);

  Future<void> _saveBill() async {
    if (_generatedItems.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('bill_history') ?? [];

    final billData = {
      'date': DateTime.now().toIso8601String(),
      'total': _totalBill,
      'items': _generatedItems.map((e) => e.toJson()).toList(),
    };

    history.add(jsonEncode(billData));
    await prefs.setStringList('bill_history', history);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Bill saved to history!')),
    );

    setState(() {
      _generatedItems.clear();
      _text = 'Press the mic and tell me what you sold...';
    });
  }

  void _shareBill() {
    if (_generatedItems.isEmpty) return;

    StringBuffer sb = StringBuffer();
    sb.writeln('🧾 *QuantaCalc AI Bill* 🧾\n');
    sb.writeln('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}');
    sb.writeln('--------------------------------');

    for (var item in _generatedItems) {
      sb.writeln('${item.name} (${item.quantity} x ₹${item.rate}) = ₹${item.total}');
    }

    sb.writeln('--------------------------------');
    sb.writeln('💰 *Total: ₹$_totalBill*');
    sb.writeln('\nThank you for visiting!');

    Share.share(sb.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart AI Assistant'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_generatedItems.isNotEmpty)
            IconButton(icon: const Icon(Icons.share), onPressed: _shareBill),
          if (_generatedItems.isNotEmpty)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveBill),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            color: Colors.deepPurple.withOpacity(0.05),
            child: Text(
              _text,
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: _generatedItems.isEmpty
                ? const Center(child: Text('Your receipt will appear here', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _generatedItems.length,
                    itemBuilder: (context, index) {
                      final item = _generatedItems[index];
                      return ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text('${item.name} (${item.quantity} x ₹${item.rate})', style: const TextStyle(fontSize: 16)),
                        trailing: Text(_currencyFormat.format(item.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    },
                  ),
          ),
          if (_generatedItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bill:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(_currencyFormat.format(_totalBill),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: InkWell(
              onTap: _listen,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red : Colors.deepPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isListening ? Colors.red.withOpacity(0.5) : Colors.deepPurple.withOpacity(0.5),
                      blurRadius: _isListening ? 30 : 10,
                      spreadRadius: _isListening ? 10 : 2,
                    )
                  ]
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.auto_awesome,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
