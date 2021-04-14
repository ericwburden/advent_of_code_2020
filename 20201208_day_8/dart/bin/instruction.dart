import 'dart:math';

enum InstructionType {
  acc,
  jmp,
  nop,
}

class Instruction {
  static final reFromString = RegExp(r'^(nop|jmp|acc)\s*(\+|\-)(\d+)$');

  late int id;
  late InstructionType type;
  late int value;

  Instruction(InstructionType type, int value) {
    id = Random().nextInt(1000);
    this.type = type;
    this.value = value;
  }

  Instruction.fromString(String s) {
    id = Random().nextInt(1000);
    var stringMatch = reFromString.firstMatch(s);
    if (stringMatch == null) {
      throw ArgumentError('Cannot parse $s into Instruction');
    }

    switch (stringMatch.group(1)!) {
      case 'acc':
        type = InstructionType.acc;
        break;
      case 'jmp':
        type = InstructionType.jmp;
        break;
      case 'nop':
        type = InstructionType.nop;
        break;
      default:
        throw ArgumentError('Cannot parse $s into Instruction');
    }

    var sign = 1;
    if (stringMatch.group(2)! == '-') {
      sign = -1;
    }
    value = int.parse(stringMatch.group(3)!) * sign;
  }

  @override
  bool operator ==(Object other) {
    return other is Instruction &&
        id == other.id &&
        type == other.type &&
        value == other.value;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ value.hashCode;
  }
}
