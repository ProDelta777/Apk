import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../models/calculation_history_item.dart';
import '../widgets/math_mesh_background.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  String _input = '';
  String _result = '0';
  final List<CalculationHistoryItem> _history = [];
  final ScrollController _scrollController = ScrollController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  bool _isCalculating = false;
  late AnimationController _resultAnimController;
  late Animation<double> _resultScaleAnim;
  late Animation<double> _resultOpacityAnim;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _resultScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _resultAnimController, curve: Curves.elasticOut),
    );

    _resultOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultAnimController, curve: Curves.easeIn),
    );

    _resultAnimController.forward();
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    super.dispose();
  }

  void _triggerResultAnimation() {
    setState(() {
      _isCalculating = true;
    });

    _resultAnimController.reset();
    _resultAnimController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    });
  }

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
          _history.add(CalculationHistoryItem(
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
        _history.add(CalculationHistoryItem(
          expression: _input,
          result: eval,
          timestamp: DateTime.now(),
        ));
        _result = _formatNumber(eval);
        _input = '';
        _scrollToBottom();
      });
      _triggerResultAnimation();
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Smart Bill Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
            tooltip: 'Clear Bill',
          ),
        ],
      ),
      body: MathMeshBackground(
        isCalculating: _isCalculating,
        child: Column(
          children: [
            // Premium Receipt View
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'RECEIPT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.cyanAccent.withOpacity(0.8),
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.formattedExpression,
                                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                                      softWrap: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    _currencyFormat.format(item.result),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            _currencyFormat.format(_totalBill),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated Input/Result Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _input,
                      style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w400, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: FadeTransition(
                        opacity: _resultOpacityAnim,
                        child: ScaleTransition(
                          scale: _resultScaleAnim,
                          child: Text(
                            _result,
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.cyanAccent, blurRadius: 20)
                              ]
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Premium Glassmorphic Tactile Keypad
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.85),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('+5% GST', color: Colors.orange.withOpacity(0.2), textColor: Colors.orangeAccent),
                        _buildButton('+18% GST', color: Colors.orange.withOpacity(0.2), textColor: Colors.orangeAccent),
                        _buildButton('-10% Disc', color: Colors.green.withOpacity(0.2), textColor: Colors.greenAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('C', color: Colors.red.withOpacity(0.2), textColor: Colors.redAccent),
                        _buildButton('⌫', color: Colors.red.withOpacity(0.2), textColor: Colors.redAccent),
                        _buildButton('%', color: Colors.white.withOpacity(0.05), textColor: Colors.cyanAccent),
                        _buildButton('/', color: Colors.white.withOpacity(0.05), textColor: Colors.cyanAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('x', color: Colors.white.withOpacity(0.05), textColor: Colors.cyanAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('-', color: Colors.white.withOpacity(0.05), textColor: Colors.cyanAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('+', color: Colors.white.withOpacity(0.05), textColor: Colors.cyanAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('00'),
                        _buildButton('0'),
                        _buildButton('.'),
                        _buildButton('=', color: Colors.cyanAccent, textColor: const Color(0xFF0F172A), isEquals: true),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, {Color? color, Color? textColor, bool isEquals = false}) {
    color ??= Colors.white.withOpacity(0.02);
    textColor ??= Colors.white;

    return _CalculatorButton(
      text: text,
      color: color,
      textColor: textColor,
      isEquals: isEquals,
      onTap: () {
        HapticFeedback.lightImpact();
        _onButtonPressed(text);
      },
    );
  }
}

class _CalculatorButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color textColor;
  final bool isEquals;
  final VoidCallback onTap;

  const _CalculatorButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.isEquals,
    required this.onTap,
  });

  @override
  State<_CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<_CalculatorButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.text.length > 5 ? 100 : 70,
          height: 64,
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: widget.isEquals ? [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 1,
              )
            ] : null,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.text.length > 5 ? 14 : 26,
              fontWeight: FontWeight.w400,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
