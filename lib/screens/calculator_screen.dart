import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '0';
  String _lastExpression = '';
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _input = '';
        _result = '0';
        _lastExpression = '';
      } else if (buttonText == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (buttonText == '=') {
        _calculateResult();
      } else {
        _input += buttonText;
      }
    });
  }

  void _calculateResult() {
    if (_input.isEmpty) return;
    try {
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(_input.replaceAll('x', '*').replaceAll('÷', '/').replaceAll(',', ''));
      ContextModel cm = ContextModel();
      // Ignoring deprecation for math_expressions evaluate as per library usage norms.
      // ignore: deprecated_member_use
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _lastExpression = _input;
        _result = _formatNumber(eval);
        _input = ''; // Clear input for next operation, but keep result shown
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  String _formatNumber(double num) {
    if (num == num.truncateToDouble()) {
      return _currencyFormat.format(num).replaceAll('.00', '');
    }
    return _currencyFormat.format(num);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _result.replaceAll('₹', '').replaceAll(',', '')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result copied to clipboard', style: TextStyle(color: Colors.white)), backgroundColor: Colors.cyan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate
      body: SafeArea(
        child: Column(
          children: [
            // Header / App Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Quanta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Calc', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2DD4BF))), // Teal Accent
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Smart Calculation Suite', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B), // Darker slate
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.camera, color: Color(0xFF2DD4BF), size: 20),
                  )
                ],
              ),
            ),

            // Display Card (Glassmorphic)
            Expanded(
              flex: 4, // Increased flex to give display more robust breathing room
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Added bottom margin to prevent overlap
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Semantics(
                          label: 'Copy',
                          child: IconButton(
                            icon: const Icon(Icons.copy_outlined, color: Colors.grey, size: 20),
                            onPressed: _copyToClipboard,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Semantics(
                          label: 'History',
                          child: IconButton(
                            icon: const Icon(Icons.history_outlined, color: Colors.grey, size: 20),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HistoryScreen()),
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 40),
                      alignment: Alignment.bottomRight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _input.isEmpty ? _lastExpression : _input,
                          style: const TextStyle(fontSize: 24, color: Colors.grey),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 70),
                      alignment: Alignment.bottomRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _result == '0' && _input.isEmpty ? '₹0' : _result,
                          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w400, color: Colors.white, height: 1.0),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Keypad area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton('AC', textColor: const Color(0xFF2DD4BF)),
                      _buildButton('%', textColor: const Color(0xFF2DD4BF)),
                      _buildButton('⌫', textColor: const Color(0xFF2DD4BF), isIcon: true, iconData: Icons.backspace_outlined),
                      _buildButton('÷', textColor: const Color(0xFF2DD4BF)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('x', textColor: const Color(0xFF2DD4BF)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('-', textColor: const Color(0xFF2DD4BF)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left block with numbers and pill button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildButton('1'),
                              const SizedBox(width: 14),
                              _buildButton('2'),
                              const SizedBox(width: 14),
                              _buildButton('3'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildButton('0', width: 160, isPill: true),
                              const SizedBox(width: 14),
                              _buildButton('.'),
                            ],
                          ),
                        ],
                      ),

                      // Right column for vertical plus and tall equals
                      Column(
                        children: [
                          _buildButton('+', textColor: const Color(0xFF2DD4BF)),
                          const SizedBox(height: 12),
                          _buildButton('=', bgColor: const Color(0xFF2DD4BF), textColor: const Color(0xFF0F172A)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    Color? textColor,
    Color? bgColor,
    bool isIcon = false,
    IconData? iconData,
    double width = 73,
    double height = 73,
    bool isPill = false,
  }) {
    return _CalculatorButton(
      text: text,
      textColor: textColor ?? Colors.white,
      bgColor: bgColor ?? const Color(0xFF1E293B),
      isIcon: isIcon,
      iconData: iconData,
      width: width,
      height: height,
      isPill: isPill,
      onTap: () {
        HapticFeedback.lightImpact();
        _onButtonPressed(text);
      },
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final bool isIcon;
  final IconData? iconData;
  final double width;
  final double height;
  final bool isPill;
  final VoidCallback onTap;

  const _CalculatorButton({
    required this.text,
    required this.textColor,
    required this.bgColor,
    this.isIcon = false,
    this.iconData,
    required this.width,
    required this.height,
    this.isPill = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = isIcon
      ? Icon(iconData, color: textColor, size: 24)
      : Text(text, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: textColor));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isPill ? 36 : 36), // always 36 to make it circular/pill
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(2, 4),
            )
          ]
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
