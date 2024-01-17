import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class MyColors {
  static const Color Peach = Color(0xFFd98c86);
  static const Color Teal = Color(0xFF4caeb3);
  static const Color DarkTeal = Color(0xFF204648);
}

class GameOfLifePage extends StatefulWidget {
  const GameOfLifePage({super.key});

  @override
  State<GameOfLifePage> createState() => _GameOfLifePageState();
}

class _GameOfLifePageState extends State<GameOfLifePage> {
  var fabText = 'Start';
  var isPlaying = false;
  int width = 30;
  int height = 30;
  List<List<Cell>> gridItems = [];

  @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void initializeGrid() {
    for (int i = 0; i < width; i++) {
      List<Cell> row = [];
      for (int j = 0; j < height; j++) {
        row.add(Cell(x: i, y: j, living: false, neighbors: 0));
      }
      gridItems.add(row);
    }
  }

  void onPressed() {
    setState(() {
      fabText = fabText == 'Start' ? 'Pause' : 'Start';
      isPlaying = !isPlaying;
      gameLoop();
    });
  }

  void gameLoop() {
    if (!isPlaying || gridItems.isEmpty) {
      return;
    }

    List<List<Cell>> newGrid = List.generate(
      height,
      (i) => List.generate(
        width,
        (j) => Cell(
            x: i,
            y: j,
            living: gridItems[i][j].living,
            neighbors: gridItems[i][j].neighbors),
      ),
    );
    //play

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        bool hasChanged = false;
        Cell cell = gridItems[i][j];
        //if living cell  has 0-1 or 4+ neighbors, kill it
        if (cell.living && (cell.neighbors <= 1 || cell.neighbors >= 4)) {
          newGrid[i][j].living = false;
          hasChanged = true;
        } //if dead cell has exactly 3 neighbors, make it alive
        else if (!cell.living && cell.neighbors == 3) {
          newGrid[i][j].living = true;
          hasChanged = true;
        }

        if (hasChanged) {
          incrementDecrementNeighbors(newGrid, i, j, newGrid[i][j].living);
        }
      }
    }
    setState(() {
      gridItems = newGrid;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      gameLoop();
    });
  }

  incrementDecrementNeighbors(grid, row, col, isLiving) {
    for (int i = -1; i < 2; i++) {
      for (int j = -1; j < 2; j++) {
        // Skip the center cell itself
        if (i == 0 && j == 0) {
          continue;
        }

        int newRow = row + i;
        int newCol = col + j;

        // Check bounds
        if (newRow >= 0 &&
            newRow < grid.length &&
            newCol >= 0 &&
            newCol < grid[0].length) {
          if (isLiving) {
            grid[newRow][newCol].neighbors++;
          } else {
            grid[newRow][newCol].neighbors--;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Center(
          child: SquaresGrid(
              isPlaying: isPlaying,
              gridItems: gridItems,
              width: width,
              height: height)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(Icons.play_arrow),
        label: Text(fabText),
      ),
    );
  }
}

class SquaresGrid extends StatefulWidget {
  bool isPlaying;
  int width;
  int height;
  List<List<Cell>> gridItems;
  SquaresGrid(
      {required this.isPlaying,
      required this.gridItems,
      required this.width,
      required this.height});
  @override
  State<SquaresGrid> createState() => _SquaresGridState();
}

class _SquaresGridState extends State<SquaresGrid> {
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
    child: GridView.builder(
      itemCount: widget.width * widget.height,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.width,
      ),
      itemBuilder: (BuildContext context, int index) {
        int row = index ~/ widget.width;
        int col = index % widget.height;

        return GestureDetector(
          onTap: () {
            setState(() {
              handleCellTap(row, col);
            });
          },
          child: Container(
            color: widget.gridItems[row][col].living
                ? MyColors.Teal
                : MyColors.DarkTeal,
            width: 8,
            height: 8,
            margin: EdgeInsets.all(.5),
            child: Center(
              child: Text(getCellText(row, col)),
            ),
          ),
        );
      },
    ));
  }

  void handleCellTap(int row, int col) {
    widget.gridItems[row][col].living = !widget.gridItems[row][col].living;
    bool isLiving = widget.gridItems[row][col].living;
    for (int i = -1; i < 2; i++) {
      for (int j = -1; j < 2; j++) {
        if (row + i < 0 ||
            col + j < 0 ||
            row + i >= widget.width ||
            col + j >= widget.height ||
            (i == 0 && j == 0)) {
          continue;
        }
        if (isLiving) {
          widget.gridItems[row + i][col + j].neighbors++;
        } else if (!isLiving &&
            row + i >= 0 &&
            col + j >= 0 &&
            row + i < widget.width &&
            col + j < widget.height) {
          widget.gridItems[row + i][col + j].neighbors--;
        }
      }
    }
  }

  String getCellText(int row, int col) {
    bool isDebug = false;
    if (widget.gridItems.isEmpty) return '';
    if (isDebug) {
      return '${widget.gridItems[row][col].neighbors}';
    }
    return '';
  }
}

class Cell extends StatefulWidget {
  int x;
  int y;
  bool living = false;
  int neighbors = 0;

  Cell(
      {required this.x,
      required this.y,
      required this.living,
      required this.neighbors});

  @override
  _CellState createState() => _CellState();
}

class _CellState extends State<Cell> {
  Color _containerColor = Colors.grey;

  void _changeColor() {
    setState(() {
      _containerColor = widget.living ? MyColors.Teal : MyColors.DarkTeal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.living = !widget.living;
          _changeColor();
        });
      },
      child: Container(
        width: 8,
        height: 8,
        color: _containerColor,
        margin: EdgeInsets.all(1),
      ),
    );
  }
}
