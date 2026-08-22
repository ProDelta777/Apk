import 'package:flutter/material.dart';

class GstCalculatorScreen extends StatefulWidget {
  const GstCalculatorScreen({super.key});

  @override
  State<GstCalculatorScreen> createState() => _GstCalculatorScreenState();
}

class _GstCalculatorScreenState extends State<GstCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  double _gstPercentage = 18.0;
  bool _isInclusive = true;

  double get _gstAmount {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_isInclusive) {
      return amount - (amount * (100 / (100 + _gstPercentage)));
    } else {
      return amount * (_gstPercentage / 100);
    }
  }

  double get _finalAmount {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_isInclusive) {
      return amount;
    } else {
      return amount + _gstAmount;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('GST Calculator', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Amount (₹)',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('GST %', style: TextStyle(color: Colors.grey.shade400)),
                        DropdownButton<double>(
                          value: _gstPercentage,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          underline: const SizedBox(),
                          items: [5.0, 12.0, 18.0, 28.0].map((double value) {
                            return DropdownMenuItem<double>(
                              value: value,
                              child: Text('${value.toInt()}%'),
                            );
                          }).toList(),
                          onChanged: (double? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _gstPercentage = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isInclusive = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isInclusive ? const Color(0xFF2DD4BF).withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _isInclusive ? const Color(0xFF2DD4BF) : Colors.grey.shade700),
                              ),
                              alignment: Alignment.center,
                              child: Text('Inclusive', style: TextStyle(color: _isInclusive ? const Color(0xFF2DD4BF) : Colors.grey.shade400)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isInclusive = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isInclusive ? const Color(0xFF2DD4BF).withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: !_isInclusive ? const Color(0xFF2DD4BF) : Colors.grey.shade700),
                              ),
                              alignment: Alignment.center,
                              child: Text('Exclusive', style: TextStyle(color: !_isInclusive ? const Color(0xFF2DD4BF) : Colors.grey.shade400)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildResultRow('Original Amount', double.tryParse(_amountController.text) ?? 0.0),
                    const SizedBox(height: 12),
                    _buildResultRow('GST Amount (${_gstPercentage.toInt()}%)', _gstAmount),
                    const Divider(color: Colors.white24, height: 32),
                    _buildResultRow('Final Amount', _finalAmount, isTotal: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey.shade400,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isTotal ? const Color(0xFF2DD4BF) : Colors.white,
            fontSize: isTotal ? 24 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
