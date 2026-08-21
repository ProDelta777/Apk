import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/math_mesh_background.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Discount Calculator'),
      ),
      body: MathMeshBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Original Price',
                  prefixText: '₹ ',
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                onChanged: (_) => _calculateDiscount(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Discount Value',
                      ),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      onChanged: (_) => _calculateDiscount(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ToggleButtons(
                      isSelected: [_isPercentage, !_isPercentage],
                      onPressed: (index) {
                        setState(() {
                          _isPercentage = index == 0;
                          _calculateDiscount();
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      selectedColor: Colors.black,
                      fillColor: Colors.pinkAccent,
                      color: Colors.white70,
                      constraints: const BoxConstraints(minHeight: 56, minWidth: 60),
                      children: const [
                        Text('%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('₹', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
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
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: Colors.pinkAccent.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.pinkAccent.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Final Price (Pay this)',
              style: TextStyle(fontSize: 16, color: Colors.pinkAccent.shade100, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              _currencyFormat.format(_finalPrice),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 10)],
              ),
            ),
            const Divider(height: 32, color: Colors.white12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('You Save:', style: TextStyle(fontSize: 18, color: Colors.greenAccent)),
                Text(
                  _currencyFormat.format(_savedAmount),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
