import 'dart:core';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class MyColors {
  static const Color Peach = Color(0xFFd98c86);
}

class GameOfLifePage extends StatefulWidget {
  const GameOfLifePage({super.key});

  @override
  State<GameOfLifePage> createState() => _GameOfLifePageState();
}

class _GameOfLifePageState extends State<GameOfLifePage> {
  var fabText = 'Start';
  var isPlaying = false;
  int width = 10; 
  int height = 10;
  List<List<GridItem>> gridItems = [];

    @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void initializeGrid() {
    for (int i = 0; i < width; i++) {
      List<GridItem> row = [];
      for (int j = 0; j < height; j++) {
        row.add(GridItem(x: i, y: j, living: false, neighbors: 0));
      }
      gridItems.add(row);
    }
  }

  void onPressed() {
    setState(() {
    fabText = fabText == 'Start' ? 'Pause' : 'Start';
    isPlaying = !isPlaying;
    gameLoop();
    }
    );
  }

  void gameLoop() {
    if (!isPlaying || gridItems.isEmpty) {
      return;
    }

     List<List<GridItem>> newGrid = List.generate(
    height,
    (i) => List.generate(
      width,
      (j) => GridItem(x: i, y: j, living: gridItems[i][j].living, neighbors: gridItems[i][j].neighbors),
    ),
  );
    //play
    for(int i = 0; i < height; i++) {
      for(int j = 0; j < width; j++) {
            //if living cell  has 0-1 or 4+ neighbors, kill it
        if (gridItems[i][j].living && (gridItems[i][j].neighbors <= 1 || gridItems[i][j].neighbors >= 4)) {
          newGrid[i][j].living = false;
        } //if dead cell has exactly 3 neighbors, make it alive
        else if (!gridItems[i][j].living && gridItems[i][j].neighbors == 3) {
          newGrid[i][j].living = true;
        }
        else {
          newGrid[i][j].living = gridItems[i][j].living;
          newGrid[i][j].neighbors = gridItems[i][j].neighbors;
        }
      incrementDecrementNeighbors(newGrid, i, j, newGrid[i][j].living);
    }

    setState(() {
      gridItems = newGrid;
    });
    
    Future.delayed(Duration(milliseconds: 500), () {
      gameLoop();
    });
  }
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
      if (newRow >= 0 && newRow < grid.length && newCol >= 0 && newCol < grid[0].length) {
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
      body: 
        Center(
          child: SquaresGrid(isPlaying: isPlaying, gridItems: gridItems, width: width, height: height)
        ),
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
  List<List<GridItem>> gridItems;
  SquaresGrid({required this.isPlaying, required this.gridItems, required this.width, required this.height});
  @override
  State<SquaresGrid> createState() => _SquaresGridState();
}

class _SquaresGridState extends State<SquaresGrid> {
  @override

  Widget build(BuildContext context) {
    return GridView.builder(
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
                ? MyColors.Peach
                : Colors.grey,
            width: 8,
            height: 8,
            margin: EdgeInsets.all(1),
            child: Center(
              child: Text(getCellText(row, col)),
            ),
          ),
        );
      },
    );
  }

  void handleCellTap(int row, int col) {
    if (widget.isPlaying) {
      return;
    }
    widget.gridItems[row][col].living = !widget.gridItems[row][col].living;
    bool isLiving = widget.gridItems[row][col].living;
    for (int i = -1; i < 2; i++) {
      for (int j = -1; j < 2; j++) {
        if ( row + i < 0 || col + j < 0 || row + i >= widget.width || col + j >= widget.height || (i == 0 && j == 0)) {
          continue;
        }
        if (isLiving) {
          widget.gridItems[row + i][col + j].neighbors++;
        }
        else if (!isLiving && row + i >= 0 && col + j >= 0 && row + i < widget.width && col + j < widget.height) {
          widget.gridItems[row + i][col + j].neighbors--;
        }
      }
    }
  }

  String getCellText(int row, int col) {
    bool isDebug = true;
    if (widget.gridItems.isEmpty)
    return '';
    if (isDebug) {
      return '(${widget.gridItems[row][col].x}, ${widget.gridItems[row][col].y}, ${widget.gridItems[row][col].neighbors})';
    }
      return '';
  }
}

class GridItem extends StatefulWidget{
  int x;
  int y;
  bool living = false;
  int neighbors = 0;

  GridItem({required this.x, required this.y, required this.living, required this.neighbors});
  
@override
  _GridItemState createState() => _GridItemState();
  }

class _GridItemState extends State<GridItem> {
  Color _containerColor = Colors.grey;

  void _changeColor() {
    setState(() {
      _containerColor = widget.living ? MyColors.Peach : Colors.grey;
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