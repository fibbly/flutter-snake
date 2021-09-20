import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Snake Game',
      home: MyHomePage(title: 'Snake Game'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Direction {
  down,
  up,
  left,
  right,
}

class _MyHomePageState extends State<MyHomePage> {
  final int startingPosition = 45;
  final int initSnakeLength = 5;
  static const int speed = 300;
  final int numberOfSquares = 760;
  final int step = 20;

  static late List<int> snakePosition;
  late int food = Random().nextInt(numberOfSquares);

  Direction direction = Direction.down;
  bool gameStarted = false;

  void generateNewFood() {
    food = Random().nextInt(numberOfSquares);
    while (snakePosition.contains(food)) {
      food = Random().nextInt(numberOfSquares);
    }
  }

  void resetSnakePosition() {
    snakePosition = List.generate(
        initSnakeLength, (index) => (index * step) + startingPosition);
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case Direction.down:
          if (snakePosition.last > (numberOfSquares - step)) {
            snakePosition.add(snakePosition.last + step - numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last + step);
          }
          break;
        case Direction.up:
          if (snakePosition.last < step) {
            snakePosition.add(snakePosition.last - step + numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last - step);
          }
          break;
        case Direction.left:
          if (snakePosition.last % step == 0) {
            snakePosition.add(snakePosition.last - 1 + step);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case Direction.right:
          if ((snakePosition.last + 1) % step == 0) {
            snakePosition.add(snakePosition.last + 1 - step);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
        default:
      }
      if (snakePosition.last == food) {
        generateNewFood();
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  void startGame() {
    resetSnakePosition();
    direction = Direction.down;
    gameStarted = true;
    const duration = Duration(milliseconds: speed);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver()) {
        timer.cancel();
        _showGameOverScreen();
      }
    });
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

  @override
  void initState() {
    snakePosition = List.generate(
        initSnakeLength, (index) => (index * step) + startingPosition);
    super.initState();
  }

  void _showGameOverScreen() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over!"),
          content: Text("Your score: ${snakePosition.length.toString()}"),
          actions: [
            TextButton(
              onPressed: () {
                startGame();
                Navigator.of(context).pop();
              },
              child: const Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (direction != Direction.up && details.delta.dy > 0) {
                      direction = Direction.down;
                    } else if (direction != Direction.down &&
                        details.delta.dy < 0) {
                      direction = Direction.up;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (direction != Direction.left && details.delta.dx > 0) {
                      direction = Direction.right;
                    } else if (direction != Direction.right &&
                        details.delta.dx < 0) {
                      direction = Direction.left;
                    }
                  },
                  child: GridView.builder(
                    itemCount: numberOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 20,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: index == food
                                  ? Colors.green
                                  : snakePosition.contains(index)
                                      ? Colors.white
                                      : Colors.grey[900],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (!gameStarted)
            Center(
              child: TextButton(
                child: const Text("Start Game"),
                onPressed: startGame,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  primary: Colors.grey[900],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
