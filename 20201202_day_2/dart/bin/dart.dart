// --- Day 2: Password Philosophy ---
//
// Your flight departs in a few days from the coastal airport; the easiest way
// down to the coast from here is via toboggan.
//
// The shopkeeper at the North Pole Toboggan Rental Shop is having a bad day.
// "Something's wrong with our computers; we can't log in!" You ask if you can
// take a look.
//
// Their password database seems to be a little corrupted: some of the passwords
// wouldn't have been allowed by the Official Toboggan Corporate Policy that was
// in effect when they were chosen.
//
// To try to debug the problem, they have created a list (your puzzle input) of
// passwords (according to the corrupted database) and the corporate policy when
// that password was set.
//
// For example, suppose you have the following list:
//
// ```
// 1-3 a: abcde
// 1-3 b: cdefg
// 2-9 c: ccccccccc
// ```
//
// Each line gives the password policy and then the password. The password
// policy indicates the lowest and highest number of times a given letter must
// appear for the password to be valid. For example, 1-3 a means that the
// password must contain a at least 1 time and at most 3 times.
//
// In the above example, 2 passwords are valid. The middle password, `cdefg`,
// is not; it contains no instances of b, but needs at least 1. The first and
// third passwords are valid: they contain one a or nine c, both within the
// limits of their respective policies.
//
// How many passwords are valid according to their policies?

// --- Part Two ---
//
// While it appears you validated the passwords correctly, they don't seem to
// be what the Official Toboggan Corporate Authentication System is expecting.
//
// The shopkeeper suddenly realizes that he just accidentally explained the
// password policy rules from his old job at the sled rental place down the
// street! The Official Toboggan Corporate Policy actually works a little
// differently.
//
// Each policy actually describes two positions in the password, where 1 means
// the first character, 2 means the second character, and so on. (Be careful;
// Toboggan Corporate Policies have no concept of "index zero"!) Exactly one of
// these positions must contain the given letter. Other occurrences of the
// letter are irrelevant for the purposes of policy enforcement.
//
// Given the same example list from above:
//
//  - `1-3 a: abcde` is valid: position 1 contains a and position 3 does not.
//  - `1-3 b: cdefg` is invalid: neither position 1 nor position 3 contains b.
//  - `2-9 c: ccccccccc` is invalid: both position 2 and position 9 contain c.
//
// How many passwords are valid according to the new interpretation of the
// policies?

import 'dart:io';

/// Represents a parsed line from the input file
class PasswordEntry {
  int number1;
  int number2;
  String testChar;
  String password;

  PasswordEntry(int number1, int number2, String testChar, String password) {
    this.number1 = number1;
    this.number2 = number2;
    this.testChar = testChar;
    this.password = password;
  }

  @override
  String toString() {
    return 'PasswordEntry($number1-$number2 $testChar: $password)';
  }

  /// Determines whether the password is valid by part one rules
  bool isValidV1() {
    var charMatches =
        password.split('').fold(0, (t, e) => (e == testChar) ? t + 1 : t);
    if (charMatches < number1 || charMatches > number2) {
      return false;
    }
    return true;
  }

  /// Determines whether the password is valid by part two rules
  bool isValidV2() {
    var chars = password.split('');
    var charAtIndex1 = chars[number1 - 1];
    var charAtIndex2 = chars[number2 - 1];

    // Evaluates to true if one is true but not both or neither
    return (charAtIndex1 == testChar) != (charAtIndex2 == testChar);
  }
}

List<PasswordEntry> readInput(String path) {
  var fileContents = File(path).readAsStringSync();
  var entries = <PasswordEntry>[];

  // All entries in the format: "nn-nn cc: ccccccccccccccccc"
  final reLine = RegExp(r'(\d+)-(\d+)\s+([a-z]):\s+([a-z]+)\n');
  var matches = reLine.allMatches(fileContents);

  // Extract the groups from the RegExpMatches
  for (var match in matches) {
    var entry = PasswordEntry(
      int.parse(match.group(1)), // number1
      int.parse(match.group(2)), // number2
      match.group(3), // testChar
      match.group(4), // password
    );
    entries.add(entry);
  }
  return entries;
}

/// Count valid entries for part one
int solvePartOne(List<PasswordEntry> input) {
  return input.fold(0, (t, e) => e.isValidV1() ? t + 1 : t);
}

/// Count valid entries for part two
int solvePartTwo(List<PasswordEntry> input) {
  return input.fold(0, (t, e) => e.isValidV2() ? t + 1 : t);
}

void main() {
  var inputFilePath = '../input.txt';
  var input = readInput(inputFilePath);

  var partOneSolution = solvePartOne(input);
  print('The answer to part one is $partOneSolution');

  var partTwoSolution = solvePartTwo(input);
  print('The answer to part two is $partTwoSolution');
}
