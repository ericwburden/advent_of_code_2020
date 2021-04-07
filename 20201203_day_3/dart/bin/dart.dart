import 'dart:io';

/// Represents the state of a given space on the map
enum CellState {
  clear,
  tree,
}

/// Represents a collection of map cells
class SkiMap {
  List<List<CellState>> cells;
  int width;
  int height;

  SkiMap(List<List<CellState>> cells) {
    this.cells = cells;
    width = cells[0].length;
    height = cells.length;
  }

  CellState stateAtPosition(int x, int y) {
    return cells[y][x];
  }

  bool isTree(int x, int y) {
    return stateAtPosition(x, y) == CellState.tree;
  }

  @override
  String toString() {
    var output = '';
    for (var row in cells) {
      for (var cell in row) {
        if (cell == CellState.tree) {
          output += '#';
        } else {
          output += '.';
        }
      }
      output += '\n';
    }
    return output;
  }
}

/// Represents the position of a skier on the map
class Skier {
  int xpos = 0;
  int ypos = 0;

  void moveDownSlope(Slope slope) {
    xpos += slope.xslope;
    ypos += slope.yslope;
  }

  @override
  String toString() {
    return 'Skier($xpos, $ypos)';
  }
}

/// Represents the slope of the skier's path
class Slope {
  int xslope;
  int yslope;

  Slope(int xslope, int yslope) {
    this.xslope = xslope;
    this.yslope = yslope;
  }
}

/// Represents a run down the slope by the skier
///
/// Provides a class to combine the map, skier, and slope and do calculations
/// with all three.
class SkiRun {
  bool finished = false;
  List<CellState> cellsTraversed = [];
  SkiMap map;
  Skier skier;
  Slope slope;

  SkiRun(SkiMap map, Skier skier, Slope slope) {
    this.map = map;
    this.skier = skier;
    this.slope = slope;
  }

  /// Move the skier one increment down the slope, correcting skier x
  /// position to allow horizontal wrapping around the map.
  void next() {
    if (!finished) {
      skier.moveDownSlope(slope);
      if (skier.xpos >= map.width) {
        skier.xpos = skier.xpos - map.width;
      }
      if (skier.ypos >= map.height) {
        finished = true;
        return;
      }
      cellsTraversed.add(map.stateAtPosition(skier.xpos, skier.ypos));
    }
  }

  /// Move the skier through the run to the bottom of the map
  void skiAllTheWayDown() {
    while (!finished) {
      next();
    }
  }

  /// Moves the skier through tne run and returns trees hit.
  int treesHit() {
    if (!finished) {
      skiAllTheWayDown();
    }
    return cellsTraversed.fold(0, (t, e) => e == CellState.tree ? t + 1 : t);
  }
}

/// Converts a character to its CellState representation
CellState charToCellState(String char) {
  if (char == '#') {
    return CellState.tree;
  }
  return CellState.clear;
}

/// Reads in an input file to a SkiMap representation
SkiMap readInput(String path) {
  var lines = File(path).readAsLinesSync();
  var cellStates = lines
      .map((line) => line.split('').map((charToCellState)).toList())
      .toList();
  return SkiMap(cellStates);
}

int solvePartOne(SkiMap map) {
  var skiRun = SkiRun(map, Skier(), Slope(3, 1));
  return skiRun.treesHit();
}

int solvePartTwo(SkiMap map) {
  var slopes = [
    Slope(1, 1),
    Slope(3, 1),
    Slope(5, 1),
    Slope(7, 1),
    Slope(1, 2),
  ];
  return slopes
      .map((slope) => SkiRun(map, Skier(), slope).treesHit())
      .reduce((a, b) => a * b);
}

void main(List<String> arguments) {
  var skiMap = readInput('../input.txt');

  var partOneSolution = solvePartOne(skiMap);
  print('The solution to part one is $partOneSolution');

  var partTwoSolution = solvePartTwo(skiMap);
  print('The solution to part two is $partTwoSolution');
}
