import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';
import '../models/bill_item.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '0';
  final List<BillItem> _history = [];
  final ScrollController _scrollController = ScrollController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _input = '';
        _result = '0';
      } else if (buttonText == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (buttonText == '=') {
        _calculateResult();
      } else if (buttonText == '+5% GST') {
        _applyPercentage(1.05, '+5% GST');
      } else if (buttonText == '+18% GST') {
        _applyPercentage(1.18, '+18% GST');
      } else if (buttonText == '-10% Disc') {
        _applyPercentage(0.90, '-10% Disc');
      } else {
        _input += buttonText;
      }
    });
  }

  void _applyPercentage(double multiplier, String label) {
    if (_input.isEmpty && _result != '0') {
      _input = _result;
    }
    if (_input.isNotEmpty) {
      try {
        GrammarParser p = GrammarParser();
        Expression exp = p.parse(_input.replaceAll('x', '*'));
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);
        double finalResult = eval * multiplier;

        setState(() {
          _history.add(BillItem(
            expression: '$_input ($label)',
            result: finalResult,
            timestamp: DateTime.now(),
          ));
          _input = '';
          _result = _formatNumber(finalResult);
          _scrollToBottom();
        });
      } catch (e) {
        setState(() {
          _result = 'Error';
        });
      }
    }
  }

  void _calculateResult() {
    if (_input.isEmpty) return;
    try {
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(_input.replaceAll('x', '*'));
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _history.add(BillItem(
          expression: _input,
          result: eval,
          timestamp: DateTime.now(),
        ));
        _result = _formatNumber(eval);
        _input = '';
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  String _formatNumber(double num) {
    if (num == num.truncateToDouble()) {
      return num.truncate().toString();
    }
    return num.toStringAsFixed(2);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
      _input = '';
      _result = '0';
    });
  }

  double get _totalBill {
    return _history.fold(0, (sum, item) => sum + item.result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Smart Bill Calculator'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
            tooltip: 'Clear Bill',
          ),
        ],
      ),
      body: Column(
        children: [
          // Receipt View
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'RECEIPT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.formattedExpression,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                              Text(
                                _currencyFormat.format(item.result),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _currencyFormat.format(_totalBill),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Input Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _input,
                  style: const TextStyle(fontSize: 24, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  _result,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Custom Keypad
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('+5% GST', color: Colors.orange[100]!, textColor: Colors.orange[900]!),
                    _buildButton('+18% GST', color: Colors.orange[100]!, textColor: Colors.orange[900]!),
                    _buildButton('-10% Disc', color: Colors.green[100]!, textColor: Colors.green[900]!),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('C', color: Colors.red[100]!, textColor: Colors.red[900]!),
                    _buildButton('⌫', color: Colors.red[100]!, textColor: Colors.red[900]!),
                    _buildButton('%', color: Colors.grey[200]!),
                    _buildButton('/', color: Colors.blue[100]!, textColor: Colors.blue[900]!),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('x', color: Colors.blue[100]!, textColor: Colors.blue[900]!),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('-', color: Colors.blue[100]!, textColor: Colors.blue[900]!),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('+', color: Colors.blue[100]!, textColor: Colors.blue[900]!),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('00'),
                    _buildButton('0'),
                    _buildButton('.'),
                    _buildButton('=', color: Colors.blueAccent, textColor: Colors.white),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButton(String text, {Color color = Colors.white, Color textColor = Colors.black87}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onButtonPressed(text),
        child: Container(
          width: text.length > 5 ? 100 : 70,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withAlpha(50)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: text.length > 5 ? 14 : 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
