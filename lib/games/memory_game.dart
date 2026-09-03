import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<_CardData> cards = [];
  int? firstFlippedIndex;
  int moves = 0;
  int bestScore = 0; // lowest moves is best
  bool isPlaying = false;
  bool isLocked = false;
  bool hapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('memory_best') ?? 0;
      hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    });
  }

  Future<void> _saveBestScore() async {
    if (bestScore == 0 || moves < bestScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('memory_best', moves);
      bestScore = moves;
    }
  }

  void startGame() {
    if (hapticFeedback) HapticFeedback.mediumImpact();
    final icons = [
      Icons.star, Icons.star,
      Icons.favorite, Icons.favorite,
      Icons.pets, Icons.pets,
      Icons.flight, Icons.flight,
      Icons.ac_unit, Icons.ac_unit,
      Icons.beach_access, Icons.beach_access,
      Icons.directions_car, Icons.directions_car,
      Icons.local_florist, Icons.local_florist,
    ];

    icons.shuffle(Random());

    setState(() {
      cards = icons.map((icon) => _CardData(icon: icon)).toList();
      moves = 0;
      firstFlippedIndex = null;
      isPlaying = true;
      isLocked = false;
    });
  }

  void _handleTap(int index) async {
    if (isLocked || cards[index].isMatched || cards[index].isFlipped) return;

    if (hapticFeedback) HapticFeedback.selectionClick();

    setState(() {
      cards[index].isFlipped = true;
    });

    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
    } else {
      setState(() {
        moves++;
        isLocked = true;
      });

      final first = firstFlippedIndex!;
      final second = index;

      if (cards[first].icon == cards[second].icon) {
        if (hapticFeedback) HapticFeedback.lightImpact();
        cards[first].isMatched = true;
        cards[second].isMatched = true;
        isLocked = false;

        if (cards.every((c) => c.isMatched)) {
          isPlaying = false;
          _saveBestScore();
          if (hapticFeedback) HapticFeedback.heavyImpact();
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            cards[first].isFlipped = false;
            cards[second].isFlipped = false;
            isLocked = false;
          });
        }
      }
      firstFlippedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Match')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moves: $moves', style: theme.textTheme.titleLarge),
                Text('Best: ${bestScore == 0 ? '-' : bestScore}', style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          if (!isPlaying && cards.isEmpty)
            Expanded(
              child: Center(
                child: FilledButton(
                  onPressed: startGame,
                  child: const Text('Start Game'),
                ),
              ),
            )
          else if (!isPlaying && cards.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('You Won!', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Text('Completed in $moves moves', style: theme.textTheme.titleLarge),
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
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: card.isFlipped || card.isMatched
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: card.isFlipped || card.isMatched
                            ? Icon(card.icon, size: 36, color: theme.colorScheme.onPrimaryContainer)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CardData {
  final IconData icon;
  bool isFlipped;
  bool isMatched;

  _CardData({
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
