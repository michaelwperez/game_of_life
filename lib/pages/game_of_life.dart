import 'dart:core';

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
  void onPressed() {
    setState(() {
    fabText = fabText == 'Start' ? 'Pause' : 'Start';
    isPlaying = !isPlaying;
    //gameLoop(widget.gridItems);
    }
    );
  }

  void gameLoop(SquaresGrid grid) {
    if (!isPlaying) {
      return;
    }
    //play
    for(int i = 0; i < grid.height; i++) {
      for(int j = 0; j < grid.width; j++) {
            //if living cell  has 0-1 or 4+ neighbors, kill it
        if (grid.gridItems[i][j].living && (grid.gridItems[i][j].neighbors <= 1 || grid.gridItems[i][j].neighbors >= 4)) {
          grid.gridItems[i][j].living = false;
          //decrement neighbors
        }
        //if dead cell has exactly 3 neighbors, make it alive
        if (!grid.gridItems[i][j].living && (grid.gridItems[i][j].neighbors == 2 || grid.gridItems[i][j].neighbors >= 3)) {
          grid.gridItems[i][j].living = true;
          //increment neighbors
      }
    }
    
    Future.delayed(Duration(milliseconds: 50), () {
      gameLoop(grid);
    });
  }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: 
        Center(
          child: SquaresGrid(isPlaying: isPlaying)
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
  int width = 10; 
  int height = 10;
  List<List<GridItem>> gridItems = [];
  SquaresGrid({required this.isPlaying});
  @override
  State<SquaresGrid> createState() => _SquaresGridState();
}

class _SquaresGridState extends State<SquaresGrid> {

  @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void initializeGrid() {
    for (int i = 0; i < widget.width; i++) {
      List<GridItem> row = [];
      for (int j = 0; j < widget.height; j++) {
        row.add(GridItem(x: i, y: j));
      }
      widget.gridItems.add(row);
    }
  }

  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.height * widget.width,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10, 
      ),
      itemBuilder: (BuildContext context, int index) {
        int row = index ~/ widget.width;
        int col = index % widget.height;
        GridItem(x: row, y: col);
      

      return GestureDetector(
        onTap: () {
          setState(() {
            if (widget.isPlaying) {
              return;
            }
            widget.gridItems[row][col].living = !widget.gridItems[row][col].living;
            bool isLiving = widget.gridItems[row][col].living;
            for (int i = -1; i < 2; i++) {
              for (int j = -1; j < 2; j++) {
                if ( row + i < 0 || col + j < 0 || row + i >= 100 || col + j >= 100 || (i == 0 && j == 0)) {
                  continue;
                }
                if (isLiving) {
                  widget.gridItems[row + i][col + j].neighbors++;
                }
                else if (!isLiving && row + i >= 0 && col + j >= 0 && row + i < 100 && col + j < 100) {
                  widget.gridItems[row + i][col + j].neighbors--;
                }
              }
            }
          });
        },
        child: Container(
            color: widget.gridItems[row][col].living ? MyColors.Peach : Colors.grey,
            width: 8,
            height: 8,
            margin: EdgeInsets.all(1), // Margin between squares
            child: Center(
              child: Text(getCellText(row, col)),
      )));
    });
  }

  String getCellText(int row, int col) {
    bool isDebug = true;
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

  GridItem({required this.x, required this.y});

  @override
  _CellState createState() {
    return _CellState();
  }
}

class _CellState extends State<GridItem> {
  Color _containerColor = Colors.grey; // Initial color of the container
  void _changeColor() {
    setState(() {
      // Change the color on tap
      _containerColor = _containerColor == MyColors.Peach ? Colors.grey : MyColors.Peach;
      //this.living = !this.living;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Call method to change the color on tap
        _changeColor();
      },
      child: Container(
        width: 8,
        height: 8,
        color: _containerColor,
        margin: EdgeInsets.all(1), // Margin between squares
          ),
        );
  }
}