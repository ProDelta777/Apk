import 'package:flutter/material.dart';

class MathMeshBackground extends StatelessWidget {
  final Widget child;
  final bool isCalculating;

  const MathMeshBackground({
    super.key,
    required this.child,
    this.isCalculating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Static dark slate background
        // Removed animations for a cleaner, modern look as requested
      ),
      child: child,
    );
  }
}
