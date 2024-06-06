double calcOneSideWeight(double load, double barWeight) {
  if (load > barWeight) {
    return (load - barWeight) / 2;
  } else {
    return 0;
  }
}

List<Map<String, String>> getPlates(
    double oneSideWeight, List<double> availablePlates, double barWeight) {
  List<double> platesToLoad = [];

  // platesToLoad = greedyApproach(oneSideWeight, availablePlates);
  platesToLoad = robustApproach(120, 20, availablePlates);
  return getPlatesMapList(platesToLoad, barWeight);
}

List<Map<String, String>> getPlatesMapList(
    List<double> platesDoubleList, double barWeight) {
  int setNum = 1;
  double progression = barWeight;
  List<Map<String, String>> platesToLoad = [];

  for (var plate in platesDoubleList) {
    platesToLoad.add({
      'set': setNum.toString(),
      'plate': plate.toString(),
      'progression': (progression + (plate * 2)).toString()
    });
    setNum++;
    progression += (plate * 2);
  }

  return platesToLoad;
}

List<double> greedyApproach(
    double oneSideWeight, List<double> availablePlates) {
  List<double> plates = [];
  int plateNum = 0;
  while (oneSideWeight > 0 && plateNum < availablePlates.length) {
    final plate = availablePlates[plateNum];
    if (plate <= oneSideWeight) {
      plates.add(plate);
      oneSideWeight -= plate;
      plateNum = 0;
    } else {
      plateNum++;
    }
  }
  return plates;
}

List<double> mathApproach(double oneSideWeight, List<double> availablePlates) {
  List<int> repRanges = [2, 3, 4];
  List<double> plates = [];
  if (oneSideWeight * 2 <= 40) {
    repRanges = [1, 2];
  }

  List<double> helper(double oneSideWeight, int numOfSets) {
    final plates = oneSideWeight / numOfSets;
    return availablePlates.contains(plates)
        ? List.filled(numOfSets, plates)
        : [];
  }

  while (oneSideWeight > 0 && plates.isEmpty) {
    for (var i = 0; i < repRanges.length; i++) {
      plates = helper(oneSideWeight, repRanges[i]);
      if (plates.isNotEmpty) {
        return plates;
      }
    }
    oneSideWeight -= 2.5;
  }

  return plates;
}

List<double> robustApproach(
    double load, double barWeight, List<double> availablePlates) {
  double oneSideWeight = calcOneSideWeight(load, barWeight);

  // Attempt the mathematical approach first
  List<double> initialPlates =
      mathApproach(oneSideWeight, availablePlates).toList();

  // If the mathematical approach yields a valid solution, validate and return it
  if (initialPlates.isNotEmpty) {
    double calcTotalWeight = totalWeight(initialPlates, barWeight);
    if (calcTotalWeight == load) {
      return initialPlates;
    }

    // If the calculated weight is slightly off, adjust using the greedy approach
    double remainingWeight = load - calcTotalWeight;
    List<double> remainingPlates =
        greedyApproach(remainingWeight / 2, availablePlates);
    initialPlates.addAll(remainingPlates);
    return initialPlates;
  }

  // Fall back to the greedy approach if the mathematical approach fails
  return greedyApproach(oneSideWeight, availablePlates);
}

double totalWeight(List<double> plates, double barWeight) {
  final totalPlateWeight = plates.reduce((sum, plate) => sum + plate) * 2;
  return totalPlateWeight + barWeight;
}
