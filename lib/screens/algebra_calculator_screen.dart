import 'package:flutter/material.dart';
import 'dart:math';

class AlgebraCalculatorScreen extends StatefulWidget {
  const AlgebraCalculatorScreen({super.key});

  @override
  State<AlgebraCalculatorScreen> createState() => _AlgebraCalculatorScreenState();
}

class _AlgebraCalculatorScreenState extends State<AlgebraCalculatorScreen> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();

  String _result = 'Enter values for ax² + bx + c = 0';

  void _solveQuadratic() {
    double a = double.tryParse(_aController.text) ?? 0;
    double b = double.tryParse(_bController.text) ?? 0;
    double c = double.tryParse(_cController.text) ?? 0;

    if (a == 0) {
      setState(() {
        _result = 'Not a quadratic equation (a cannot be 0)';
      });
      return;
    }

    double discriminant = (b * b) - (4 * a * c);

    setState(() {
      if (discriminant > 0) {
        double root1 = (-b + sqrt(discriminant)) / (2 * a);
        double root2 = (-b - sqrt(discriminant)) / (2 * a);
        _result = 'x₁ = ${root1.toStringAsFixed(2)}\nx₂ = ${root2.toStringAsFixed(2)}';
      } else if (discriminant == 0) {
        double root = -b / (2 * a);
        _result = 'x = ${root.toStringAsFixed(2)}';
      } else {
        double realPart = -b / (2 * a);
        double imaginaryPart = sqrt(-discriminant) / (2 * a);
        _result = 'x₁ = ${realPart.toStringAsFixed(2)} + ${imaginaryPart.toStringAsFixed(2)}i\nx₂ = ${realPart.toStringAsFixed(2)} - ${imaginaryPart.toStringAsFixed(2)}i';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Quadratic Solver', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
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
                    const Text('ax² + bx + c = 0', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildInput('a', _aController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInput('b', _bController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInput('c', _cController)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Roots', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(_result, style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 24, fontWeight: FontWeight.bold)),
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
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 20),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      ),
      onChanged: (_) => _solveQuadratic(),
    );
  }
}
