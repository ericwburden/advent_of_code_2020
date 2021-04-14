import 'instruction.dart';

enum ProfilerState {
  pending,
  error,
  success,
}

class Profiler {
  int currentLine = 0;
  int accumulator = 0;
  ProfilerState state = ProfilerState.pending;
  Set<int> history = {};

  late List<Instruction> instructions;

  Profiler(List<Instruction> instructions) {
    this.instructions = instructions;
  }

  Profiler.fromStrings(List<String> strings) {
    instructions = strings.map((s) => Instruction.fromString(s)).toList();
  }

  Profiler.cloneFrom(Profiler other) {
    currentLine = other.currentLine;
    accumulator = other.accumulator;
    state = other.state;
    history = Set.from(other.history);
    instructions = List.from(other.instructions);
  }

  Instruction get currentInstruction {
    return instructions[currentLine];
  }

  void runCurrentInstruction() {
    var previousLine = currentLine;
    if (history.contains(previousLine)) {
      state = ProfilerState.error;
      return;
    }
    switch (currentInstruction.type) {
      case InstructionType.acc:
        {
          accumulator += currentInstruction.value;
          currentLine += 1;
        }
        break;
      case InstructionType.jmp:
        currentLine += currentInstruction.value;
        break;
      case InstructionType.nop:
        currentLine += 1;
        break;
    }
    if (currentLine >= instructions.length) state = ProfilerState.success;
    history.add(previousLine);
  }

  void undoLastInstruction() {
    var previousInstruction = instructions[history.last];
    switch (previousInstruction.type) {
      case InstructionType.acc:
        {
          accumulator -= previousInstruction.value;
          currentLine -= 1;
        }
        break;
      case InstructionType.jmp:
        currentLine -= previousInstruction.value;
        break;
      case InstructionType.nop:
        currentLine -= 1;
        break;
    }
    state = ProfilerState.pending;
    history.remove(history.last);
  }

  void run() {
    while (state == ProfilerState.pending) {
      runCurrentInstruction();
    }
  }

  void runUntilInstruction(int id) {
    while (currentInstruction.id != id) {
      runCurrentInstruction();
    }
  }

  @override
  String toString() {
    var totalInstructions = instructions.length;
    var instructionsRun = history.length;
    return '''Profiler {
      status: $state
      current line: $currentLine
      accumulator: $accumulator
      total instructions: $totalInstructions
      instructions called: $instructionsRun
      call history: $history
    }''';
  }
}
