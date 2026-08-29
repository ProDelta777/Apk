import 'package:flutter/material.dart';
import 'dart:math';

class GeometryCalculatorScreen extends StatefulWidget {
  const GeometryCalculatorScreen({super.key});

  @override
  State<GeometryCalculatorScreen> createState() => _GeometryCalculatorScreenState();
}

class _GeometryCalculatorScreenState extends State<GeometryCalculatorScreen> {
  String _selectedShape = 'Circle';
  final TextEditingController _param1Controller = TextEditingController();
  final TextEditingController _param2Controller = TextEditingController();

  double _area = 0;
  double _perimeter = 0;

  void _calculate() {
    double p1 = double.tryParse(_param1Controller.text) ?? 0;
    double p2 = double.tryParse(_param2Controller.text) ?? 0;

    setState(() {
      if (_selectedShape == 'Circle') {
        _area = pi * p1 * p1;
        _perimeter = 2 * pi * p1; // Circumference
      } else if (_selectedShape == 'Square') {
        _area = p1 * p1;
        _perimeter = 4 * p1;
      } else if (_selectedShape == 'Rectangle') {
        _area = p1 * p2;
        _perimeter = 2 * (p1 + p2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Geometry Area', style: TextStyle(color: Colors.white)),
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
                    DropdownButtonFormField<String>(
                      value: _selectedShape,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Shape',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                      ),
                      items: ['Circle', 'Square', 'Rectangle'].map((shape) {
                        return DropdownMenuItem(value: shape, child: Text(shape));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedShape = val!;
                          _param1Controller.clear();
                          _param2Controller.clear();
                          _area = 0;
                          _perimeter = 0;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _param1Controller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                      decoration: InputDecoration(
                        labelText: _selectedShape == 'Circle' ? 'Radius' : _selectedShape == 'Square' ? 'Side Length' : 'Length',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                    if (_selectedShape == 'Rectangle')
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextField(
                          controller: _param2Controller,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                          decoration: InputDecoration(
                            labelText: 'Width',
                            labelStyle: TextStyle(color: Colors.grey.shade400),
                            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          ),
                          onChanged: (_) => _calculate(),
                        ),
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
                    _buildResultRow('Area', _area),
                    const SizedBox(height: 12),
                    _buildResultRow(_selectedShape == 'Circle' ? 'Circumference' : 'Perimeter', _perimeter),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        Text(val.toStringAsFixed(2), style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
