import 'dart:math';
import 'package:flutter/material.dart';

class MathMeshBackground extends StatefulWidget {
  final Widget child;
  final bool isCalculating;

  const MathMeshBackground({
    super.key,
    required this.child,
    this.isCalculating = false,
  });

  @override
  State<MathMeshBackground> createState() => _MathMeshBackgroundState();
}

class _MathMeshBackgroundState extends State<MathMeshBackground> with TickerProviderStateMixin {
  late AnimationController _meshController;
  late AnimationController _symbolsController;
  late AnimationController _mascotController;
  late AnimationController _calcPulseController;

  final Random _random = Random();
  final List<_FloatingSymbol> _symbols = [];

  @override
  void initState() {
    super.initState();

    // Premium slow-moving dark mesh
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    // Slower, elegant floating symbols
    _symbolsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Subtle mascot floating
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Subtle pulse for calculation events
    _calcPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _initSymbols();
  }

  void _initSymbols() {
    const chars = ['+', '−', '×', '÷', '=', '%', '√', 'π', '∑', '∫', '∞', '0', '1'];
    for (int i = 0; i < 20; i++) {
      _symbols.add(_FloatingSymbol(
        char: chars[_random.nextInt(chars.length)],
        xOffset: _random.nextDouble(),
        yOffset: _random.nextDouble(),
        speed: 0.1 + _random.nextDouble() * 0.4,
        scale: 0.8 + _random.nextDouble() * 1.2,
        opacity: 0.02 + _random.nextDouble() * 0.08, // Very subtle opacity for dark theme
        rotSpeed: (_random.nextDouble() - 0.5) * 1.5,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant MathMeshBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCalculating && !oldWidget.isCalculating) {
      // Trigger a subtle pulse animation when calculation starts
      _calcPulseController.forward(from: 0.0).then((_) => _calcPulseController.reverse());
    }
  }

  @override
  void dispose() {
    _meshController.dispose();
    _symbolsController.dispose();
    _mascotController.dispose();
    _calcPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Premium Dark Mesh Background with Calculation Pulse
        AnimatedBuilder(
          animation: Listenable.merge([_meshController, _calcPulseController]),
          builder: (context, child) {
            return CustomPaint(
              painter: _DarkMeshPainter(
                progress: _meshController.value,
                pulseIntensity: _calcPulseController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // 2. Floating Mathematical Symbols
        AnimatedBuilder(
          animation: _symbolsController,
          builder: (context, child) {
            return Stack(
              children: _symbols.map((sym) {
                // Calculate position with continuous wrapping
                double currentY = (sym.yOffset - (_symbolsController.value * sym.speed)) % 1.0;
                if (currentY < 0) currentY += 1.0;

                return Positioned(
                  left: MediaQuery.of(context).size.width * sym.xOffset,
                  top: MediaQuery.of(context).size.height * currentY,
                  child: Transform.rotate(
                    angle: _symbolsController.value * pi * 2 * sym.rotSpeed,
                    child: Transform.scale(
                      scale: sym.scale,
                      child: Text(
                        sym.char,
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.cyanAccent.withOpacity(sym.opacity),
                          fontWeight: FontWeight.w300,
                          shadows: [
                            Shadow(color: Colors.cyanAccent.withOpacity(sym.opacity * 0.5), blurRadius: 10)
                          ]
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        // 3. Subtle Premium Mascot (Abstract Quantum Cube)
        Positioned(
          top: 60,
          right: 20,
          child: AnimatedBuilder(
            animation: _mascotController,
            builder: (context, child) {
              final floatOffset = sin(_mascotController.value * pi) * 15;
              final rotOffset = cos(_mascotController.value * pi) * 0.1;
              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: Transform.rotate(
                  angle: rotOffset,
                  child: Opacity(
                    opacity: 0.15,
                    child: _buildPremiumMascot(),
                  ),
                ),
              );
            },
          ),
        ),

        // 4. The Actual Screen Content
        widget.child,
      ],
    );
  }

  Widget _buildPremiumMascot() {
    // A premium, futuristic geometric mascot (The Quantum Cube)
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.cyanAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(-10, -10),
          )
        ],
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 5,
              )
            ]
          ),
        ),
      ),
    );
  }
}

class _FloatingSymbol {
  final String char;
  final double xOffset;
  final double yOffset;
  final double speed;
  final double scale;
  final double opacity;
  final double rotSpeed;

  _FloatingSymbol({
    required this.char,
    required this.xOffset,
    required this.yOffset,
    required this.speed,
    required this.scale,
    required this.opacity,
    required this.rotSpeed,
  });
}

class _DarkMeshPainter extends CustomPainter {
  final double progress;
  final double pulseIntensity;

  _DarkMeshPainter({required this.progress, required this.pulseIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Deep Fintech Slate Base
    final Paint bgPaint = Paint()..color = const Color(0xFF0B1121);
    canvas.drawRect(rect, bgPaint);

    // Smooth moving glowing orbs for dark mode
    final Paint cyanBlob = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.05 + (0.05 * pulseIntensity))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    final Paint purpleBlob = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.03 + (0.04 * pulseIntensity))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);

    // Path 1 (Figure 8 movement)
    final double cx1 = size.width * (0.5 + 0.4 * sin(progress * pi * 2));
    final double cy1 = size.height * (0.5 + 0.3 * sin(progress * pi * 4));

    // Path 2 (Circular movement)
    final double cx2 = size.width * (0.5 + 0.3 * cos(progress * pi * 2));
    final double cy2 = size.height * (0.5 + 0.4 * sin(progress * pi * 2));

    canvas.drawCircle(Offset(cx1, cy1), size.width * 0.7, cyanBlob);
    canvas.drawCircle(Offset(cx2, cy2), size.width * 0.8, purpleBlob);
  }

  @override
  bool shouldRepaint(covariant _DarkMeshPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulseIntensity != pulseIntensity;
  }
}
