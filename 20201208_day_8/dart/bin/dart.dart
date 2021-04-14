import 'dart:io';
import 'instruction.dart';
import 'profiler.dart';

Profiler profilerFromFile(String path) {
  var lines = File(path).readAsLinesSync().map((s) => s.trim()).toList();
  return Profiler.fromStrings(lines);
}

int solvePartOne(Profiler profiler) {
  profiler.run();
  return profiler.accumulator;
}

int? solvePartTwo(Profiler profiler) {
  // Checking the current line provides a safety valve to prevent infinite loops
  while (profiler.currentLine >= 0) {
    // Undo the last instruction. If you're still on an ACC instruction, skip
    // this loop and try again.
    profiler.undoLastInstruction();
    if (profiler.currentInstruction.type == InstructionType.acc) continue;

    // Copy the profiler in its current state
    var subProfiler = Profiler.cloneFrom(profiler);

    // Switch the current JMP/NOP
    if (subProfiler.currentInstruction.type == InstructionType.nop) {
      subProfiler.currentInstruction.type = InstructionType.jmp;
    }
    if (subProfiler.currentInstruction.type == InstructionType.jmp) {
      subProfiler.currentInstruction.type = InstructionType.nop;
    }

    // Run the subProfiler, and if it passes, return the accumulator total
    subProfiler.run();
    if (subProfiler.state == ProfilerState.success) {
      return subProfiler.accumulator;
    }
  }
}

void main(List<String> arguments) {
  var profiler = profilerFromFile('../input.txt');

  var partOneSolution = solvePartOne(profiler);
  print('The solution to part one is $partOneSolution'); // 1217

  var partTwoSolution = solvePartTwo(profiler);
  print('The solution to part two is $partTwoSolution'); // 501
}
