import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Bhaav (Rate) Calculator'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price (Rate)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('₹ ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                        const Text(' per ', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        DropdownButton<String>(
                          value: _selectedBaseUnit,
                          underline: const SizedBox(),
                          style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
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
            const Icon(Icons.arrow_downward, color: Colors.grey, size: 32),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I need...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Quantity',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedTargetUnit,
                          underline: const SizedBox(),
                          style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withAlpha(50), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currencyFormat.format(_calculatedPrice),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
