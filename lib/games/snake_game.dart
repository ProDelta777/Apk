import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int rows = 20;
  static const int columns = 20;
  static const int squareSize = 15;

  List<int> snakePosition = [45, 65, 85, 105, 125];
  int numberOfSquares = rows * columns;

  int food = Random().nextInt(400);
  Timer? timer;
  String direction = 'down';
  bool isPlaying = false;
  int score = 0;

  void startGame() {
    setState(() {
      isPlaying = true;
    });

    snakePosition = [45, 65, 85, 105, 125];
    direction = 'down';
    score = 0;

    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 200), (Timer t) {
      updateSnake();
      if (gameOver()) {
        t.cancel();
        showGameOverScreen();
      }
    });
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > numberOfSquares - columns) {
            snakePosition.add(snakePosition.last + columns - numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last + columns);
          }
          break;
        case 'up':
          if (snakePosition.last < columns) {
            snakePosition.add(snakePosition.last - columns + numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last - columns);
          }
          break;
        case 'left':
          if (snakePosition.last % columns == 0) {
            snakePosition.add(snakePosition.last - 1 + columns);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % columns == 0) {
            snakePosition.add(snakePosition.last + 1 - columns);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
      }

      if (snakePosition.last == food) {
        generateNewFood();
        score++;
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  void generateNewFood() {
    food = Random().nextInt(numberOfSquares);
    while (snakePosition.contains(food)) {
      food = Random().nextInt(numberOfSquares);
    }
  }

  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count += 1;
        }
        if (count == 2) {
          return true;
        }
      }
    }
    return false;
  }

  void showGameOverScreen() {
    setState(() {
      isPlaying = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score: $score'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Snake Game - Score: $score', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: numberOfSquares,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (snakePosition.contains(index)) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == food) {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(color: Colors.green)),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(color: Colors.grey[900])),
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: isPlaying ? null : startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    isPlaying ? 'Playing...' : 'Start Game',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
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
