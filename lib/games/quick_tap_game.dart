import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class QuickTapGame extends StatefulWidget {
  const QuickTapGame({super.key});

  @override
  State<QuickTapGame> createState() => _QuickTapGameState();
}

class _QuickTapGameState extends State<QuickTapGame> {
  int score = 0;
  int bestScore = 0;
  bool isPlaying = false;
  double top = 0;
  double left = 0;
  final random = Random();
  int timeLeft = 20;
  bool hapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('quick_tap_best') ?? 0;
      hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    });
  }

  Future<void> _saveBestScore() async {
    if (score > bestScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quick_tap_best', score);
      bestScore = score;
    }
  }

  void startGame() {
    if (hapticFeedback) HapticFeedback.mediumImpact();
    setState(() {
      score = 0;
      timeLeft = 20;
      isPlaying = true;
    });
    _moveTarget();
    _tick();
  }

  void _tick() async {
    while (isPlaying && timeLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !isPlaying) return;
      setState(() {
        timeLeft--;
        if (timeLeft == 0) {
          isPlaying = false;
          _saveBestScore();
          if (hapticFeedback) HapticFeedback.heavyImpact();
        }
      });
    }
  }

  void _moveTarget() {
    setState(() {
      top = random.nextDouble() * 0.8;
      left = random.nextDouble() * 0.8;
    });
  }

  void _handleTap() {
    if (!isPlaying) return;
    if (hapticFeedback) HapticFeedback.lightImpact();
    setState(() {
      score++;
    });
    _moveTarget();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Tap')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: theme.textTheme.titleLarge),
                Text('Time: ${timeLeft}s', style: theme.textTheme.titleLarge),
                Text('Best: $bestScore', style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          Expanded(
            child: !isPlaying && timeLeft == 20
                ? Center(child: FilledButton(onPressed: startGame, child: const Text('Start Game')))
                : !isPlaying && timeLeft == 0
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Game Over!', style: theme.textTheme.headlineMedium),
                            const SizedBox(height: 16),
                            Text('Final Score: $score', style: theme.textTheme.titleLarge),
                            const SizedBox(height: 24),
                            FilledButton(onPressed: startGame, child: const Text('Play Again')),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Positioned(
                                top: constraints.maxHeight * top,
                                left: constraints.maxWidth * left,
                                child: GestureDetector(
                                  onTap: _handleTap,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.touch_app, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
