import 'field.dart' show Field;
import 'height.dart' show Height, HeightUnit;

class Passport {
  static final reYearField = RegExp(r'(\w+):(\d{4})');
  static final reHeightField = RegExp(r'(\w+):(\d+)(in|cm)?');
  static final reStringField = RegExp(r'(\w+):([#\w]+)');

  Map<String, Field> fields = {};

  static Field<int> yrFieldFromString(String fieldString) {
    var matches = Passport.reYearField.firstMatch(fieldString);
    if (matches == null) {
      throw ArgumentError(
          '"$fieldString" is not in a valid year field format.');
    }

    var label = matches.group(1)!;
    var value = int.parse(matches.group(2)!);
    return Field(label, value);
  }

  static Field<Height> hgtFieldFromString(String fieldString) {
    var matches = Passport.reHeightField.firstMatch(fieldString);
    if (matches == null) {
      throw ArgumentError(
          '"$fieldString" is not in a valid height field format.');
    }

    var label = matches.group(1)!;
    var value = int.parse(matches.group(2)!);
    var unitMatch = matches.group(3);

    var unit;
    if (unitMatch == null) {
      unit = HeightUnit.undefined;
    } else {
      unit = Height.parseUnit(unitMatch);
    }
    var height = Height(value, unit);
    return Field(label, height);
  }

  static Field<String> strFieldFromString(String fieldString) {
    var matches = Passport.reStringField.firstMatch(fieldString);
    if (matches == null) {
      throw ArgumentError('"$fieldString" is not in a valid field format.');
    }

    var label = matches.group(1)!;
    var value = matches.group(2)!;
    return Field(label, value);
  }

  static Passport parseFromString(String passportString) {
    var passport = Passport();
    var fieldStrings = passportString.split(' ');

    for (var fieldString in fieldStrings) {
      passport.addFieldFromString(fieldString);
    }

    return passport;
  }

  void addFieldFromString(String input) {
    var key = input.substring(0, 3);
    if (fields.containsKey(key)) {
      throw ArgumentError('Passport already contains a "$key" field');
    }

    var field;
    if (key == 'hgt') {
      field = Passport.hgtFieldFromString(input);
    } else if (['byr', 'iyr', 'eyr'].contains(key)) {
      field = Passport.yrFieldFromString(input);
    } else {
      field = Passport.strFieldFromString(input);
    }
    fields[key] = field;
  }

  bool isValidV1() {
    var requiredFields = ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'];
    for (var name in requiredFields) {
      if (!fields.containsKey(name)) {
        return false;
      }
    }
    return true;
  }

  bool isValidV2() {
    var requiredFields = ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'];
    for (var name in requiredFields) {
      var field = fields[name];
      if (field == null) return false;
      if (!field.isValidV2()) return false;
    }
    return true;
  }

  @override
  String toString() {
    var passportString = 'Passport(';
    for (var field in fields.values) {
      passportString += field.toString() + '; ';
    }
    passportString.substring(0, passportString.length - 2);
    passportString += ')';
    return passportString;
  }
}
