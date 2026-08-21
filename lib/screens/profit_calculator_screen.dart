import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/math_mesh_background.dart';

class ProfitCalculatorScreen extends StatefulWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  final _costController = TextEditingController();
  final _sellController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  double _profitAmount = 0;
  double _profitMargin = 0;
  double _totalProfit = 0;
  bool _isLoss = false;

  void _calculateProfit() {
    final cost = double.tryParse(_costController.text) ?? 0;
    final sell = double.tryParse(_sellController.text) ?? 0;
    final qty = double.tryParse(_quantityController.text) ?? 1;

    if (cost > 0) {
      setState(() {
        _profitAmount = sell - cost;
        _isLoss = _profitAmount < 0;
        _profitMargin = (_profitAmount / cost) * 100;
        _totalProfit = _profitAmount * qty;
      });
    } else {
      setState(() {
        _profitAmount = 0;
        _profitMargin = 0;
        _totalProfit = 0;
        _isLoss = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profit Calculator'),
      ),
      body: MathMeshBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kharid Rate (Cost Price)',
                  prefixText: '₹ ',
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                onChanged: (_) => _calculateProfit(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sellController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bikri Rate (Sell Price)',
                  prefixText: '₹ ',
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                onChanged: (_) => _calculateProfit(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity (Items Sold)',
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                onChanged: (_) => _calculateProfit(),
              ),
              const SizedBox(height: 32),
              if (_costController.text.isNotEmpty && _sellController.text.isNotEmpty) ...[
                _buildResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    Color statusColor = _isLoss ? Colors.redAccent : Colors.greenAccent;
    String statusText = _isLoss ? 'Nuksan (Loss)' : 'Munafa (Profit)';

    return Card(
      color: statusColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: statusColor,
                shadows: [Shadow(color: statusColor.withOpacity(0.5), blurRadius: 10)],
                letterSpacing: 1.5,
              ),
            ),
            const Divider(height: 32, color: Colors.white12),
            _buildResultRow('Per Item Amount', _currencyFormat.format(_profitAmount.abs()), statusColor),
            const SizedBox(height: 16),
            _buildResultRow('Margin (%)', '${_profitMargin.abs().toStringAsFixed(2)}%', statusColor),
            const Divider(height: 32, color: Colors.white12),
            _buildResultRow('Total (Qty x Amount)', _currencyFormat.format(_totalProfit.abs()), statusColor, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
