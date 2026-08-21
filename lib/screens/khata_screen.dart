import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../widgets/math_mesh_background.dart';

class KhataScreen extends StatefulWidget {
  const KhataScreen({super.key});

  @override
  State<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends State<KhataScreen> {
  Map<String, double> _khataData = {};
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKhata();
  }

  Future<void> _loadKhata() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('udhar_khata');
    if (data != null) {
      setState(() {
        _khataData = Map<String, double>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveKhata() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('udhar_khata', jsonEncode(_khataData));
  }

  void _addEntry({bool isPayment = false}) {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) return;

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) return;

    setState(() {
      double currentDue = _khataData[name] ?? 0;
      if (isPayment) {
        currentDue -= amount;
      } else {
        currentDue += amount;
      }

      if (currentDue == 0) {
        _khataData.remove(name);
      } else {
        _khataData[name] = currentDue;
      }
    });

    _saveKhata();
    _nameController.clear();
    _amountController.clear();
    Navigator.pop(context);
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => _addEntry(isPayment: true),
            child: const Text('Received'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => _addEntry(isPayment: false),
            child: const Text('Gave (Udhar)'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear account for $name?'),
        content: const Text('This will set their due to ₹0 and remove them from the list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _khataData.remove(name);
              });
              _saveKhata();
              Navigator.pop(context);
            },
            child: const Text('Clear Account', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  double get _totalMarketDue {
    return _khataData.values.where((v) => v > 0).fold(0.0, (sum, v) => sum + v);
  }

  double get _totalAdvance {
    return _khataData.values.where((v) => v < 0).fold(0.0, (sum, v) => sum + v).abs();
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = _khataData.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Udhar Khata'),
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          backgroundColor: Colors.cyanAccent,
          icon: const Icon(Icons.add, color: Color(0xFF0F172A)),
          label: const Text('Add Entry', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        ),
      ),
      body: MathMeshBackground(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Total Udhar', style: TextStyle(color: Colors.redAccent.shade100, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(_currencyFormat.format(_totalMarketDue), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.redAccent)),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Column(
                    children: [
                      Text('Advance', style: TextStyle(color: Colors.greenAccent.shade100, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(_currencyFormat.format(_totalAdvance), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _khataData.isEmpty
                  ? const Center(child: Text('No udhar records.', style: TextStyle(color: Colors.white54, fontSize: 18)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        final name = sortedKeys[index];
                        final amount = _khataData[name]!;
                        final isAdvance = amount < 0;

                        return Card(
                          color: const Color(0xFF1E293B).withOpacity(0.6),
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.white12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isAdvance ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: isAdvance ? Colors.greenAccent : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                            subtitle: Text(isAdvance ? 'Advance' : 'To Receive', style: TextStyle(color: Colors.white54)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currencyFormat.format(amount.abs()),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isAdvance ? Colors.greenAccent : Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.white38),
                                  onPressed: () => _showClearConfirmDialog(name),
                                )
                              ],
                            ),
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
