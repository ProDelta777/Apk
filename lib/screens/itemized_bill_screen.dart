import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../models/bill_item.dart';

class ItemizedBillScreen extends StatefulWidget {
  const ItemizedBillScreen({super.key});

  @override
  State<ItemizedBillScreen> createState() => _ItemizedBillScreenState();
}

class _ItemizedBillScreenState extends State<ItemizedBillScreen> {
  final List<BillItem> _items = [];
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  final _quantityController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  double get _totalBill => _items.fold(0, (sum, item) => sum + item.total);

  void _addItem() {
    if (_nameController.text.isEmpty ||
        _rateController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final rate = double.tryParse(_rateController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;

    if (rate <= 0 || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid rate or quantity')),
      );
      return;
    }

    setState(() {
      _items.add(BillItem(name: _nameController.text, rate: rate, quantity: quantity));
    });

    _nameController.clear();
    _rateController.clear();
    _quantityController.clear();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _saveBill() async {
    if (_items.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('bill_history') ?? [];

    final billData = {
      'date': DateTime.now().toIso8601String(),
      'total': _totalBill,
      'items': _items.map((e) => e.toJson()).toList(),
    };

    history.add(jsonEncode(billData));
    await prefs.setStringList('bill_history', history);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill saved to history!')),
    );

    setState(() {
      _items.clear();
    });
  }

  void _shareBill() {
    if (_items.isEmpty) return;

    StringBuffer sb = StringBuffer();
    sb.writeln('🧾 *QuantaCalc Bill* 🧾\n');
    sb.writeln('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}');
    sb.writeln('--------------------------------');

    for (var item in _items) {
      sb.writeln('${item.name} (${item.quantity} x ₹${item.rate}) = ₹${item.total}');
    }

    sb.writeln('--------------------------------');
    sb.writeln('💰 *Total: ₹$_totalBill*');
    sb.writeln('\nThank you for visiting!');

    Share.share(sb.toString());
  }

  void _showChangeCalculator() {
    showDialog(
      context: context,
      builder: (context) {
        final amountGivenController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double amountGiven = double.tryParse(amountGivenController.text) ?? 0;
            double change = amountGiven - _totalBill;

            return AlertDialog(
              title: const Text('Return Change Calculator'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Bill: ${_currencyFormat.format(_totalBill)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountGivenController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount Given by Customer (₹)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  if (amountGivenController.text.isNotEmpty)
                    Text(
                      change >= 0
                          ? 'Return: ${_currencyFormat.format(change)}'
                          : 'Due: ${_currencyFormat.format(change.abs())}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: change >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itemized Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareBill,
            tooltip: 'Share Bill',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBill,
            tooltip: 'Save Bill',
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Item Name (e.g. Aloo)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rate', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Icon(Icons.add),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text('${item.name} (${item.quantity} x ₹${item.rate})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_currencyFormat.format(item.total),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Bill:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(_currencyFormat.format(_totalBill),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _items.isEmpty ? null : _showChangeCalculator,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Change', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
