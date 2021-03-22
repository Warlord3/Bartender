class PumpConfiguration {
  List<int> beverageIDs = List<int>.filled(16, 5);
  List<int> mlPerMinute = List<int>.filled(16, 100);
  PumpConfiguration.testData() {
    beverageIDs = List<int>.generate(16, (index) => index);
    mlPerMinute = List<int>.generate(16, (index) => 100);
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
