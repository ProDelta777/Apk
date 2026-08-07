import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() => _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isPercentage = true; // true = %, false = Flat Amount

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  double _savedAmount = 0;
  double _finalPrice = 0;

  void _calculateDiscount() {
    final originalPrice = double.tryParse(_priceController.text) ?? 0;
    final discountValue = double.tryParse(_discountController.text) ?? 0;

    if (originalPrice > 0 && discountValue >= 0) {
      setState(() {
        if (_isPercentage) {
          _savedAmount = originalPrice * (discountValue / 100);
        } else {
          _savedAmount = discountValue;
        }

        // Prevent final price from going below zero
        if (_savedAmount > originalPrice) {
          _savedAmount = originalPrice;
        }

        _finalPrice = originalPrice - _savedAmount;
      });
    } else {
      setState(() {
        _savedAmount = 0;
        _finalPrice = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Original Price',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _calculateDiscount(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Discount Value',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) => _calculateDiscount(),
                  ),
                ),
                const SizedBox(width: 16),
                ToggleButtons(
                  isSelected: [_isPercentage, !_isPercentage],
                  onPressed: (index) {
                    setState(() {
                      _isPercentage = index == 0;
                      _calculateDiscount();
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: Colors.pinkAccent,
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('%')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('₹')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_priceController.text.isNotEmpty && _discountController.text.isNotEmpty) ...[
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Final Price (Pay this)',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(_finalPrice),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('You Save:', style: TextStyle(fontSize: 16, color: Colors.green)),
                Text(
                  _currencyFormat.format(_savedAmount),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
