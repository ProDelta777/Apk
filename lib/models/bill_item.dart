class BillItem {
  final String expression;
  final double result;
  final DateTime timestamp;

  BillItem({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  String get formattedExpression => expression.replaceAll('*', 'x');
}
