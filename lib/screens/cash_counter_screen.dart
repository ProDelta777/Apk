import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/math_mesh_background.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Cash Counter (Galla)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          )
        ],
      ),
      body: MathMeshBackground(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                border: const Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                children: [
                  const Text('Total Cash', style: TextStyle(fontSize: 16, color: Colors.white54, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(_currencyFormat.format(_totalCash),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
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
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                          ),
                          child: Text(
                            '₹$denom',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.greenAccent),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('x', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white54)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: TextField(
                              controller: _controllers[denom],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: '0',
                                contentPadding: EdgeInsets.zero,
                                fillColor: const Color(0xFF1E293B).withOpacity(0.6),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('=', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white54)),
                        const SizedBox(width: 16),
                        Container(
                          width: 100,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _currencyFormat.format(rowTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
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
      ),
    );
  }
}
