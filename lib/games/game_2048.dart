import 'dart:math' show max;
import 'dart:math' as math;
import 'package:flutter/material.dart';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  static const int gridSize = 4;
  late List<List<int>> grid;
  int score = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    initGrid();
  }

  void initGrid() {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    score = 0;
    gameOver = false;
    addRandomTile();
    addRandomTile();
  }

  void addRandomTile() {
    List<List<int>> emptyCells = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final random = math.Random();
      final cell = emptyCells[random.nextInt(emptyCells.length)];
      grid[cell[0]][cell[1]] = random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  void move(String direction) {
    if (gameOver) return;

    bool moved = false;
    List<List<int>> newGrid = List.generate(gridSize, (_) => List.filled(gridSize, 0));

    // Rotate grid to process all movements as 'left'
    int rotations = 0;
    switch (direction) {
      case 'up': rotations = 3; break;
      case 'right': rotations = 2; break;
      case 'down': rotations = 1; break;
      case 'left': rotations = 0; break;
    }

    // Apply rotations
    var tempGrid = grid;
    for (int i = 0; i < rotations; i++) {
      tempGrid = rotateRight(tempGrid);
    }

    // Process left movement
    for (int i = 0; i < gridSize; i++) {
      List<int> row = tempGrid[i].where((val) => val != 0).toList();
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j] == row[j + 1]) {
          row[j] *= 2;
          score += row[j];
          row[j + 1] = 0;
        }
      }
      row = row.where((val) => val != 0).toList();
      while (row.length < gridSize) {
        row.add(0);
      }
      if (row.toString() != tempGrid[i].toString()) {
        moved = true;
      }
      newGrid[i] = row;
    }

    // Un-rotate
    tempGrid = newGrid;
    for (int i = 0; i < (4 - rotations) % 4; i++) {
      tempGrid = rotateRight(tempGrid);
    }

    if (moved) {
      setState(() {
        grid = tempGrid;
        addRandomTile();
        checkGameOver();
      });
    }
  }

  List<List<int>> rotateRight(List<List<int>> inputGrid) {
    List<List<int>> newGrid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        newGrid[j][gridSize - 1 - i] = inputGrid[i][j];
      }
    }
    return newGrid;
  }

  void checkGameOver() {
    bool hasEmpty = false;
    bool hasMatch = false;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) {
          hasEmpty = true;
        }
        if (j < gridSize - 1 && grid[i][j] == grid[i][j + 1]) {
          hasMatch = true;
        }
        if (i < gridSize - 1 && grid[i][j] == grid[i + 1][j]) {
          hasMatch = true;
        }
      }
    }

    if (!hasEmpty && !hasMatch) {
      setState(() {
        gameOver = true;
      });
    }
  }

  Color getTileColor(int value) {
    switch (value) {
      case 2: return Colors.orange[50]!;
      case 4: return Colors.orange[100]!;
      case 8: return Colors.orange[200]!;
      case 16: return Colors.orange[300]!;
      case 32: return Colors.orange[400]!;
      case 64: return Colors.orange[500]!;
      case 128: return Colors.orange[600]!;
      case 256: return Colors.orange[700]!;
      case 512: return Colors.orange[800]!;
      case 1024: return Colors.orange[900]!;
      case 2048: return Colors.red[500]!;
      default: return Colors.grey[800]!;
    }
  }

  Color getTextColor(int value) {
    return value < 8 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('2048', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                initGrid();
              });
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Score: $score', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! < 0) move('up');
              else if (details.primaryVelocity! > 0) move('down');
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) move('left');
              else if (details.primaryVelocity! > 0) move('right');
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  int row = index ~/ gridSize;
                  int col = index % gridSize;
                  int val = grid[row][col];
                  return Container(
                    decoration: BoxDecoration(
                      color: val == 0 ? Colors.grey[800] : getTileColor(val),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        val == 0 ? '' : '$val',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(val),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (gameOver)
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  const Text('Game Over!', style: TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        initGrid();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
