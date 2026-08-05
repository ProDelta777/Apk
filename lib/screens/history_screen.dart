import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../models/bill_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyStrings = prefs.getStringList('bill_history') ?? [];

    setState(() {
      _history = historyStrings.map((str) => jsonDecode(str) as Map<String, dynamic>).toList();
      _history.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bill_history');
    setState(() {
      _history.clear();
    });
  }

  void _shareSavedBill(Map<String, dynamic> bill) {
    final items = (bill['items'] as List).map((e) => BillItem.fromJson(e)).toList();
    final date = _dateFormat.format(DateTime.parse(bill['date']));
    final total = bill['total'];

    StringBuffer sb = StringBuffer();
    sb.writeln('🧾 *QuantaCalc Saved Bill* 🧾\n');
    sb.writeln('Date: $date');
    sb.writeln('--------------------------------');

    for (var item in items) {
      sb.writeln('${item.name} (${item.quantity} x ₹${item.rate}) = ₹${item.total}');
    }

    sb.writeln('--------------------------------');
    sb.writeln('💰 *Total: ₹$total*');
    sb.writeln('\nThank you for visiting!');

    Share.share(sb.toString());
  }

  void _showBillDetails(Map<String, dynamic> bill) {
    final items = (bill['items'] as List).map((e) => BillItem.fromJson(e)).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Bill from ${_dateFormat.format(DateTime.parse(bill['date']))}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.quantity} x ₹${item.rate}'),
                  trailing: Text(_currencyFormat.format(item.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _shareSavedBill(bill);
              },
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History?'),
                  content: const Text('Are you sure you want to delete all saved bills?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        _clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear History',
          )
        ],
      ),
      body: _history.isEmpty
          ? const Center(child: Text('No history available.'))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final bill = _history[index];
                final date = DateTime.parse(bill['date']);
                final total = bill['total'];
                final itemCount = (bill['items'] as List).length;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(_currencyFormat.format(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('${_dateFormat.format(date)} • $itemCount items'),
                    trailing: IconButton(
                      icon: const Icon(Icons.share, color: Colors.blueAccent),
                      onPressed: () => _shareSavedBill(bill),
                    ),
                    onTap: () => _showBillDetails(bill),
                  ),
                );
              },
            ),
    );
  }
}
