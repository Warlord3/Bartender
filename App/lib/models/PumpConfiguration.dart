class PumpConfiguration {
  List<int> beverageIDs = List<int>.filled(16, 5);
  List<int> mlPerMinute = List<int>.filled(16, 5);
  PumpConfiguration.testData() {
    beverageIDs = List<int>.filled(16, 5);
    mlPerMinute = List<int>.filled(16, 5);
  }
  bool get configurated {
    return !beverageIDs.any((element) => element == -1) &&
        !mlPerMinute.any((element) => element == 0);
  }

  void setBeverageID(int index, int id) {
    beverageIDs[index] = id;
  }

  void setMlPerMinute(int index, int ml) {
    mlPerMinute[index] = ml;
  }
}
