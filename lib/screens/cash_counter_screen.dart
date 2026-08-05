import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashCounterScreen extends StatefulWidget {
  const CashCounterScreen({super.key});

  @override
  State<CashCounterScreen> createState() => _CashCounterScreenState();
}

class _CashCounterScreenState extends State<CashCounterScreen> {
  final List<int> _denominations = [500, 200, 100, 50, 20, 10, 5, 2, 1];
  final Map<int, TextEditingController> _controllers = {};
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    for (var denom in _denominations) {
      _controllers[denom] = TextEditingController();
    }
  }

  double get _totalCash {
    double total = 0;
    for (var denom in _denominations) {
      final count = int.tryParse(_controllers[denom]?.text ?? '0') ?? 0;
      total += denom * count;
    }
    return total;
  }

  void _clearAll() {
    setState(() {
      for (var denom in _denominations) {
        _controllers[denom]?.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Counter (Galla)'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Total Cash: ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(_currencyFormat.format(_totalCash),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _denominations.length,
              itemBuilder: (context, index) {
                final denom = _denominations[index];
                final count = int.tryParse(_controllers[denom]?.text ?? '0') ?? 0;
                final rowTotal = denom * count;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹$denom',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('x', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _controllers[denom],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Notes',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('=', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: Text(
                          _currencyFormat.format(rowTotal),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
