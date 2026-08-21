import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/math_mesh_background.dart';

class RateCalculatorScreen extends StatefulWidget {
  const RateCalculatorScreen({super.key});

  @override
  State<RateCalculatorScreen> createState() => _RateCalculatorScreenState();
}

class _RateCalculatorScreenState extends State<RateCalculatorScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedBaseUnit = '1 kg';
  String _selectedTargetUnit = 'gm';

  double _calculatedPrice = 0.0;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  final List<String> _baseUnits = ['1 kg', '100 gm', '1 Ltr', '1 Dozen', '1 Piece'];
  final List<String> _targetUnits = ['kg', 'gm', 'Ltr', 'ml', 'Pieces'];

  void _calculate() {
    double? price = double.tryParse(_priceController.text);
    double? weight = double.tryParse(_weightController.text);

    if (price == null || weight == null) {
      setState(() {
        _calculatedPrice = 0.0;
      });
      return;
    }

    double baseWeightInGrams = 1000.0; // default for 1 kg
    if (_selectedBaseUnit == '100 gm') baseWeightInGrams = 100.0;
    if (_selectedBaseUnit == '1 Ltr') baseWeightInGrams = 1000.0; // assuming Ltr to ml mapping is similar
    if (_selectedBaseUnit == '1 Dozen') baseWeightInGrams = 12.0;
    if (_selectedBaseUnit == '1 Piece') baseWeightInGrams = 1.0;

    double targetWeightInGrams = weight;
    if (_selectedTargetUnit == 'kg' || _selectedTargetUnit == 'Ltr') targetWeightInGrams = weight * 1000.0;

    double pricePerGram = price / baseWeightInGrams;

    setState(() {
      _calculatedPrice = pricePerGram * targetWeightInGrams;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Bhaav (Rate) Calculator'),
      ),
      body: MathMeshBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price (Rate)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyanAccent.withOpacity(0.8), letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('₹ ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                              ),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              onChanged: (_) => _calculate(),
                            ),
                          ),
                          const Text(' per ', style: TextStyle(fontSize: 18, color: Colors.white54)),
                          DropdownButton<String>(
                            value: _selectedBaseUnit,
                            underline: const SizedBox(),
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(fontSize: 20, color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                            items: _baseUnits.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedBaseUnit = newValue!;
                                _calculate();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.arrow_downward, color: Colors.white24, size: 32),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I need...',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purpleAccent.withOpacity(0.8), letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Quantity',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                              ),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              onChanged: (_) => _calculate(),
                            ),
                          ),
                          DropdownButton<String>(
                            value: _selectedTargetUnit,
                            underline: const SizedBox(),
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(fontSize: 20, color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                            items: _targetUnits.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTargetUnit = newValue!;
                                _calculate();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.2), width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(fontSize: 16, color: Colors.cyanAccent.withOpacity(0.8), letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currencyFormat.format(_calculatedPrice),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
