import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
        title: const Text('Udhar Khata'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          backgroundColor: Colors.redAccent,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Entry', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.redAccent.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Total Udhar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    Text(_currencyFormat.format(_totalMarketDue), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Advance', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text(_currencyFormat.format(_totalAdvance), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _khataData.isEmpty
                ? const Center(child: Text('No udhar records.'))
                : ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      final name = sortedKeys[index];
                      final amount = _khataData[name]!;
                      final isAdvance = amount < 0;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAdvance ? Colors.green.shade100 : Colors.red.shade100,
                          child: Text(name[0].toUpperCase(), style: TextStyle(color: isAdvance ? Colors.green : Colors.red)),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(isAdvance ? 'Advance' : 'To Receive'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currencyFormat.format(amount.abs()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isAdvance ? Colors.green : Colors.red,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
                              onPressed: () => _showClearConfirmDialog(name),
                            )
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
