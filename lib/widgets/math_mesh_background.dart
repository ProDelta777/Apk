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

  final Random _random = Random();
  final List<_FloatingSymbol> _symbols = [];

  @override
  void initState() {
    super.initState();

    // Very slow mesh background animation
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Floating symbols animation
    _symbolsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Subtle mascot floating
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _initSymbols();
  }

  void _initSymbols() {
    const chars = ['+', '−', '×', '÷', '=', '%', '√', 'π', '<', '>', '0', '1', '4', '9'];
    for (int i = 0; i < 25; i++) {
      _symbols.add(_FloatingSymbol(
        char: chars[_random.nextInt(chars.length)],
        xOffset: _random.nextDouble(),
        yOffset: _random.nextDouble(),
        speed: 0.2 + _random.nextDouble() * 0.8,
        scale: 0.5 + _random.nextDouble() * 1.5,
        opacity: 0.05 + _random.nextDouble() * 0.15,
        rotSpeed: (_random.nextDouble() - 0.5) * 2,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant MathMeshBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCalculating != oldWidget.isCalculating) {
      if (widget.isCalculating) {
        _meshController.duration = const Duration(seconds: 5);
        _meshController.repeat();
      } else {
        _meshController.duration = const Duration(seconds: 20);
        _meshController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _meshController.dispose();
    _symbolsController.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Mesh Gradient Background
        AnimatedBuilder(
          animation: _meshController,
          builder: (context, child) {
            return CustomPaint(
              painter: _MeshPainter(
                progress: _meshController.value,
                intensity: widget.isCalculating ? 1.5 : 0.5,
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
                          color: Colors.blueAccent.withOpacity(sym.opacity),
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        // 3. Subtle Original Math Mascot (A cute abstract geometric shape or panda-like figure)
        Positioned(
          top: 60,
          right: 20,
          child: AnimatedBuilder(
            animation: _mascotController,
            builder: (context, child) {
              final floatOffset = sin(_mascotController.value * pi) * 10;
              final rotOffset = cos(_mascotController.value * pi) * 0.05;
              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: Transform.rotate(
                  angle: rotOffset,
                  child: Opacity(
                    opacity: 0.15,
                    child: _buildMascot(),
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

  Widget _buildMascot() {
    // Original abstract math mascot (e.g., a cute rounded calculator robot/animal)
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Eyes
          Positioned(top: 20, left: 15, child: _circle(8, Colors.black)),
          Positioned(top: 20, right: 15, child: _circle(8, Colors.black)),
          // Math symbol on belly
          const Positioned(
            bottom: 15,
            child: Text('π', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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

class _MeshPainter extends CustomPainter {
  final double progress;
  final double intensity;

  _MeshPainter({required this.progress, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Base gentle gradient
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade50,
          Colors.blue.shade50.withOpacity(0.5),
          Colors.purple.shade50.withOpacity(0.3),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Subtle moving soft blobs to create a mesh feel
    final Paint blobPaint1 = Paint()
      ..color = Colors.blue.withOpacity(0.05 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    final Paint blobPaint2 = Paint()
      ..color = Colors.purple.withOpacity(0.03 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    final double cx1 = size.width * (0.5 + 0.3 * sin(progress * pi * 2));
    final double cy1 = size.height * (0.3 + 0.2 * cos(progress * pi * 2));

    final double cx2 = size.width * (0.2 + 0.4 * cos(progress * pi * 2));
    final double cy2 = size.height * (0.7 + 0.3 * sin(progress * pi * 2));

    canvas.drawCircle(Offset(cx1, cy1), 200, blobPaint1);
    canvas.drawCircle(Offset(cx2, cy2), 250, blobPaint2);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.intensity != intensity;
  }
}
