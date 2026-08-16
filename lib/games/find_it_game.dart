import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class FindItGame extends StatefulWidget {
  const FindItGame({super.key});

  @override
  State<FindItGame> createState() => _FindItGameState();
}

class _FindItGameState extends State<FindItGame> {
  int score = 0;
  int bestScore = 0;
  int timeLeft = 30;
  bool isPlaying = false;
  late _Target currentTarget;
  List<_Target> items = [];
  final random = Random();
  bool hapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('find_it_best') ?? 0;
      hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    });
  }

  Future<void> _saveBestScore() async {
    if (score > bestScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('find_it_best', score);
      bestScore = score;
    }
  }

  void startGame() {
    if (hapticFeedback) HapticFeedback.mediumImpact();
    setState(() {
      score = 0;
      timeLeft = 30;
      isPlaying = true;
      _generateRound();
    });
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

  void _generateRound() {
    final shapes = [Icons.circle, Icons.square, Icons.star, Icons.favorite, Icons.change_history];
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange];

    items.clear();
    for (int i = 0; i < 16; i++) {
      items.add(_Target(
        shape: shapes[random.nextInt(shapes.length)],
        color: colors[random.nextInt(colors.length)],
        id: i,
      ));
    }

    currentTarget = items[random.nextInt(items.length)];
  }

  void _handleTap(_Target target) {
    if (!isPlaying) return;

    if (target.id == currentTarget.id) {
      if (hapticFeedback) HapticFeedback.lightImpact();
      setState(() {
        score += 10;
        _generateRound();
      });
    } else {
      if (hapticFeedback) HapticFeedback.vibrate();
      setState(() {
        score = max(0, score - 5);
      });
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.orange) return 'Orange';
    return '';
  }

  String _getShapeName(IconData shape) {
    if (shape == Icons.circle) return 'Circle';
    if (shape == Icons.square) return 'Square';
    if (shape == Icons.star) return 'Star';
    if (shape == Icons.favorite) return 'Heart';
    if (shape == Icons.change_history) return 'Triangle';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Find It')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: theme.textTheme.titleLarge),
                Text('Time: ${timeLeft}s', style: theme.textTheme.titleLarge?.copyWith(
                  color: timeLeft <= 10 ? Colors.red : null
                )),
                Text('Best: $bestScore', style: theme.textTheme.titleLarge),
              ],
            ),
          ),

          if (!isPlaying && timeLeft == 30)
            Expanded(
              child: Center(
                child: FilledButton(
                  onPressed: startGame,
                  child: const Text('Start Game'),
                ),
              ),
            )
          else if (!isPlaying && timeLeft == 0)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Game Over!', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Text('Final Score: $score', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: startGame,
                      child: const Text('Play Again'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Find the ${_getColorName(currentTarget.color)} ${_getShapeName(currentTarget.shape)}',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GestureDetector(
                          onTap: () => _handleTap(item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.shape, color: item.color, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Target {
  final IconData shape;
  final Color color;
  final int id;
  _Target({required this.shape, required this.color, required this.id});
}
