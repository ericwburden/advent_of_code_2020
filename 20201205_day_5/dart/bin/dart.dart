import 'dart:io' show File;
import 'dart:math' show max;

final List<int> rowNumbers = List.generate(128, (i) => i);
final List<int> columnNumbers = List.generate(8, (i) => i);

class BinarySearchException implements Exception {
  String errMsg() => 'Could not settle on a single item';
}

class BoardingPass {
  final List<bool> rowDirections = [];
  final List<bool> columnDirections = [];

  BoardingPass(String passString) {
    passString.split('').forEach((ch) {
      switch (ch) {
        case 'F':
          rowDirections.add(true);
          return;
        case 'B':
          rowDirections.add(false);
          return;
        case 'L':
          columnDirections.add(true);
          return;
        case 'R':
          columnDirections.add(false);
          return;
        default:
          throw ArgumentError('Not a valid boarding pass character.');
      }
    });
  }

  int rowNumber() {
    var idx = getBinarySearchIndex(0, 127, rowDirections);
    return rowNumbers[idx];
  }

  int columnNumber() {
    var idx = getBinarySearchIndex(0, 7, columnDirections);
    return columnNumbers[idx];
  }

  int seatNumber() {
    return (rowNumber() * 8) + columnNumber();
  }
}

int getBinarySearchIndex(int start, int end, List<bool> boolList) {
  for (var frontHalf in boolList) {
    var halfway = ((end - start) / 2) + start;
    if (frontHalf) {
      end = halfway.floor();
    } else {
      start = halfway.ceil();
    }
  }
  if (start != end) throw BinarySearchException();
  return start;
}

void main(List<String> arguments) {
  var boardingPasses = File('../input.txt')
      .readAsLinesSync()
      .map((s) => BoardingPass(s))
      .toList();
  var seatNumbers = boardingPasses.map((bp) => bp.seatNumber()).toList();

  // Solution to part one
  var partOneSolution = seatNumbers.reduce(max);
  print('The solution to part one is $partOneSolution');

  // Solution to part two
  seatNumbers.sort();
  var partTwoSolution;
  for (var i = 1; i < seatNumbers.length; i++) {
    var prev = seatNumbers[i - 1];
    var curr = seatNumbers[i];
    if (prev != curr - 1) {
      partTwoSolution = prev + 1;
    }
  }
  print('The solution to part two is $partTwoSolution');
}
