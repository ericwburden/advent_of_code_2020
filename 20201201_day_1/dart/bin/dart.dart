/// --- Day 1: Report Repair ---
///
/// After saving Christmas five years in a row, you've decided to take a
/// vacation at a nice resort on a tropical island. Surely, Christmas will go on
/// without you.
///
/// The tropical island has its own currency and is entirely cash-only. The gold
/// coins used there have a little picture of a starfish; the locals just call
/// them stars. None of the currency exchanges seem to have heard of them, but
/// somehow, you'll need to find fifty of these coins by the time you arrive so
/// you can pay the deposit on your room.
///
/// To save your vacation, you need to get all fifty stars by December 25th.
///
/// Collect stars by solving puzzles. Two puzzles will be made available on
/// each day in the Advent calendar; the second puzzle is unlocked when you
/// complete the first. Each puzzle grants one star. Good luck!
///
/// Before you leave, the Elves in accounting just need you to fix your expense
/// report (your puzzle input); apparently, something isn't quite adding up.
///
/// Specifically, they need you to find the two entries that sum to 2020 and
/// then multiply those two numbers together.
///
/// For example, suppose your expense report contained the following:
/// > 1721
/// > 979
/// > 366
/// > 299
/// > 675
/// > 1456
///
/// In this list, the two entries that sum to 2020 are 1721 and 299. Multiplying
/// them together produces 1721 * 299 = 514579, so the correct answer is 514579.
///
/// Of course, your expense report is much larger. Find the two entries that sum
/// to 2020; what do you get if you multiply them together?

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';

/// Returns a sorted list of the numbers in the input file.
///
/// Assumes that that input file is a text file where each line contains an
/// integer and nothing else.
Future<List<int>> readInput(String path) async {
  var ints = await File(path)
      .openRead()
      .map(utf8.decode)
      .transform(LineSplitter())
      .map(int.parse)
      .toList();
  ints.sort();
  return ints;
}

/// Finds two numbers in a list that add to a given total
Tuple2<int, int>? findTwoAddends(List<int> nums, int total) {
  var p1 = 0;
  var p2 = nums.length - 1;

  while (p1 < p2) {
    var currentSum = nums[p1] + nums[p2];
    if (currentSum == total) {
      return Tuple2(nums[p1], nums[p2]);
    }
    if (currentSum < total) {
      p1++;
    }
    if (currentSum > total) {
      p2--;
    }
  }
  return null;
}

/// Solves part one of the puzzle.
Future<int?> partOne(int total, String path) async {
  var nums = await readInput(path);
  var addends = findTwoAddends(nums, total);
  if (addends == null) {
    return null;
  }
  return addends.item1 * addends.item2;
}

/// Solves part two of the puzzle.
Future<int?> partTwo(int total, String path) async {
  var nums = await readInput(path);
  var diffs = nums.map((n) => total - n).toList();

  for (var idx = 0; idx < nums.length; idx++) {
    var addends = findTwoAddends(nums.sublist(idx), diffs[idx]);
    if (addends != null) {
      if (nums[idx] + addends.item1 + addends.item2 == total) {
        return nums[idx] * addends.item1 * addends.item2;
      }
    }
  }
  return null;
}

/// Solves the puzzle and prints the solution to the console.
void main(List<String> arguments) async {
  var partOneSolution = await partOne(2020, '../input.txt');
  if (partOneSolution != null) {
    print('The solution to part one is $partOneSolution!'); // 55776
  } else {
    print('Could not solve part one.');
  }

  var partTwoSolution = await partTwo(2020, '../input.txt');
  if (partTwoSolution != null) {
    print('The solution to part two is $partTwoSolution!'); // 223162626
  } else {
    print('Could not solve part two.');
  }
}
