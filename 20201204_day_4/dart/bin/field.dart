import 'height.dart' show Height;

class Field<T> {
  static final reValidHairColor = RegExp(r'^#[0-9a-f]{6}$');
  static final reValidPid = RegExp(r'^\d{9}$');
  late String label;
  late T value;

  Field(this.label, this.value);

  @override
  String toString() {
    return 'Field($label: $value)';
  }

  bool isValidV2() {
    switch (label) {
      case 'byr':
        return value as int >= 1920 && value as int <= 2002;
      case 'iyr':
        return value as int >= 2010 && value as int <= 2020;
      case 'eyr':
        return value as int >= 2020 && value as int <= 2030;
      case 'hgt':
        return (value as Height).isValidV2();
      case 'hcl':
        return Field.reValidHairColor.hasMatch(value as String);
      case 'ecl':
        return ['amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth']
            .contains(value as String);
      case 'pid':
        return Field.reValidPid.hasMatch(value as String);
      case 'cid':
        return true;
      default:
        throw ArgumentError('"$label" is not a valid field name.');
    }
  }
}
