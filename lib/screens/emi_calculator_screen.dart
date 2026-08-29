import 'package:flutter/material.dart';
import 'dart:math';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();

  double _emi = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;

  void _calculateEmi() {
    double p = double.tryParse(_principalController.text) ?? 0;
    double r = double.tryParse(_rateController.text) ?? 0;
    double t = double.tryParse(_tenureController.text) ?? 0;

    if (p > 0 && r > 0 && t > 0) {
      double rMonthly = r / (12 * 100); // one month interest
      double tMonths = t * 12; // one month period

      _emi = (p * rMonthly * pow(1 + rMonthly, tMonths)) / (pow(1 + rMonthly, tMonths) - 1);
      _totalPayment = _emi * tMonths;
      _totalInterest = _totalPayment - p;
    } else {
      _emi = 0;
      _totalPayment = 0;
      _totalInterest = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('EMI Calculator', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
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
                    _buildInput('Loan Amount (₹)', _principalController),
                    const SizedBox(height: 16),
                    _buildInput('Interest Rate (%) p.a.', _rateController),
                    const SizedBox(height: 16),
                    _buildInput('Loan Tenure (Years)', _tenureController),
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
                    _buildResultRow('Monthly EMI', _emi, isTotal: true),
                    const Divider(color: Colors.white24, height: 32),
                    _buildResultRow('Total Interest', _totalInterest),
                    const SizedBox(height: 12),
                    _buildResultRow('Total Payment', _totalPayment),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 20),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      ),
      onChanged: (_) => _calculateEmi(),
    );
  }

  Widget _buildResultRow(String label, double val, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.white : Colors.grey.shade400, fontSize: isTotal ? 18 : 16)),
        Text('₹${val.toStringAsFixed(2)}', style: TextStyle(color: isTotal ? const Color(0xFF2DD4BF) : Colors.white, fontSize: isTotal ? 28 : 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
