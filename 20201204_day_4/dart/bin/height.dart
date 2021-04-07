enum HeightUnit {
  inches,
  centimeters,
  undefined,
}

class Height {
  late int value;
  late HeightUnit units;

  static HeightUnit parseUnit(String suffix) {
    if (suffix == 'in') {
      return HeightUnit.inches;
    }
    if (suffix == 'cm') {
      return HeightUnit.centimeters;
    }
    return HeightUnit.undefined;
  }

  Height(this.value, this.units);

  @override
  String toString() {
    var unitString = units.toString().split('.').last;
    return '$value $unitString';
  }

  bool isValidV2() {
    switch (units) {
      case HeightUnit.centimeters:
        return value >= 150 && value <= 193;
      case HeightUnit.inches:
        return value >= 59 && value <= 76;
      default:
        return false;
    }
  }
}
