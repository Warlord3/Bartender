class Command {
  String command;
  Command({this.command});

  factory Command.fromJson(Map<String, dynamic> parsedJson) {
    return new Command(
        command: parsedJson['command'] == null ? "" : parsedJson['command']);
  }
}

class Status extends Command {
  int numberPumpsRunning;
  int drinkID;
  int progress;
  List<PumpStatus> pumpStatus;
  Status({
    String command,
    this.numberPumpsRunning,
    this.drinkID,
    this.progress,
    this.pumpStatus,
  }) : super(command: command);
  Map<String, dynamic> toJson() => {
        'command': command,
        'numberPumpsRunning': numberPumpsRunning,
        'drinkID': drinkID,
        'progress': progress,
        'pumpStatus': pumpStatus,
      };

  factory Status.fromJson(Map<String, dynamic> parsedJson) {
    return new Status(
        numberPumpsRunning: parsedJson['numberPumpsRunning'] == null
            ? 0
            : parsedJson['numberPumpsRunning'],
        drinkID: parsedJson['drinkID'] == null ? -1 : parsedJson['drinkID'],
        progress: parsedJson['progress'] == null ? -1 : parsedJson['progress'],
        pumpStatus: parsedJson['pumpStatus'] == null
            ? null
            : (parsedJson['pumpStatus'] as List)
                .map((i) => PumpStatus.fromJson(i))
                .toList(),
        command: parsedJson['command']);
  }
}

class PumpStatus {
  int ID;
  int beverageID;
  int amount; //Amount that the Pumps already delivered
  int percent;
  PumpStatus({this.ID, this.beverageID, this.amount, this.percent});
  factory PumpStatus.fromJson(Map<String, dynamic> json) => PumpStatus(
        ID: json["ID"] == null ? -1 : json["ID"],
        beverageID: json["beverageID"] == null ? -1 : json["beverageID"],
        amount: json["amount"] == null ? 0 : json["amount"],
        percent: json["percent"] == null ? 0 : json["percent"],
      );
}

class Progress extends Command {
  int progress;
  Progress({
    String command,
    this.progress,
  }) : super(command: command);

  factory Progress.fromJson(Map<String, dynamic> parsedJson) => Progress(
        command: parsedJson['command'] == null ? "" : parsedJson['command'],
        progress: parsedJson['progress'] == null ? 0 : parsedJson['progress'],
      );
}
