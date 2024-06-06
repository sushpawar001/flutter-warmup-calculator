List<double> stringToDoubleList(String str) {
  final list = str.split(",");
  return list.map((elem) {
    try {
      return double.parse(elem);
    } on FormatException {
      throw ArgumentError("$elem is not a valid double");
    }
  }).toList();
}

List<num> convertDoubleToIntIfWhole(List<num> inputList) {
  return inputList
      .map((e) => e is double && e == e.toInt() ? e.toInt() : e)
      .toList();
}
