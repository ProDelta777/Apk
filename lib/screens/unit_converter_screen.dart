import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _category = 'Length';
  String _fromUnit = 'Meter';
  String _toUnit = 'Kilometer';
  double _result = 0.0;

  final Map<String, List<String>> _units = {
    'Length': ['Meter', 'Kilometer', 'Centimeter', 'Inch', 'Foot'],
    'Weight': ['Kilogram', 'Gram', 'Pound', 'Ounce'],
    'Temperature': ['Celsius', 'Fahrenheit', 'Kelvin'],
  };

  void _convert() {
    double input = double.tryParse(_inputController.text) ?? 0.0;

    if (_category == 'Length') {
      double inMeters = input;
      switch (_fromUnit) {
        case 'Kilometer': inMeters = input * 1000; break;
        case 'Centimeter': inMeters = input / 100; break;
        case 'Inch': inMeters = input * 0.0254; break;
        case 'Foot': inMeters = input * 0.3048; break;
      }

      switch (_toUnit) {
        case 'Meter': _result = inMeters; break;
        case 'Kilometer': _result = inMeters / 1000; break;
        case 'Centimeter': _result = inMeters * 100; break;
        case 'Inch': _result = inMeters / 0.0254; break;
        case 'Foot': _result = inMeters / 0.3048; break;
      }
    } else if (_category == 'Weight') {
       double inKg = input;
      switch (_fromUnit) {
        case 'Gram': inKg = input / 1000; break;
        case 'Pound': inKg = input * 0.453592; break;
        case 'Ounce': inKg = input * 0.0283495; break;
      }

      switch (_toUnit) {
        case 'Kilogram': _result = inKg; break;
        case 'Gram': _result = inKg * 1000; break;
        case 'Pound': _result = inKg / 0.453592; break;
        case 'Ounce': _result = inKg / 0.0283495; break;
      }
    } else if (_category == 'Temperature') {
      double inCelsius = input;
      if (_fromUnit == 'Fahrenheit') {
        inCelsius = (input - 32) * 5/9;
      } else if (_fromUnit == 'Kelvin') {
        inCelsius = input - 273.15;
      }

      if (_toUnit == 'Celsius') {
        _result = inCelsius;
      } else if (_toUnit == 'Fahrenheit') {
        _result = (inCelsius * 9/5) + 32;
      } else if (_toUnit == 'Kelvin') {
        _result = inCelsius + 273.15;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Unit Converter', style: TextStyle(color: Colors.white)),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    items: _units.keys.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _category = val!;
                        _fromUnit = _units[_category]![0];
                        _toUnit = _units[_category]![1];
                        _convert();
                      });
                    },
                  ),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white, fontSize: 24),
                            decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.grey)),
                            onChanged: (_) => _convert(),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _fromUnit,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 16),
                          items: _units[_category]!.map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (val) {
                            setState(() { _fromUnit = val!; _convert(); });
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 32),
                     Row(
                      children: [
                        Expanded(
                          child: Text(
                            _result.toStringAsFixed(4).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _toUnit,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 16),
                          items: _units[_category]!.map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (val) {
                            setState(() { _toUnit = val!; _convert(); });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
