import 'dart:io' show File;
import 'passport.dart' show Passport;

List<String> readInput(String path) {
  var inputLines = File(path).readAsLinesSync();
  var passportStrings = <String>[];
  var passportBuffer = '';

  for (var line in inputLines) {
    if (line == '') {
      passportStrings.add(passportBuffer.trim());
      passportBuffer = '';
    } else {
      passportBuffer += line.trim() + ' ';
    }
  }
  passportStrings.add(passportBuffer.trim());

  return passportStrings;
}

int solvePartOne(List<Passport> passports) {
  return passports
      .map((p) => p.isValidV1())
      .fold<int>(0, (t, n) => n ? t + 1 : t);
}

int solvePartTwo(List<Passport> passports) {
  return passports
      .map((p) => p.isValidV2())
      .fold<int>(0, (t, n) => n ? t + 1 : t);
}

void main(List<String> arguments) {
  var passports = readInput('../input.txt')
      .map((s) => Passport.parseFromString(s))
      .toList();

  var partOneSolution = solvePartOne(passports);
  print('The solution to part one is $partOneSolution');

  var partTwoSolution = solvePartTwo(passports);
  print('The solution to part two is $partTwoSolution');
}
