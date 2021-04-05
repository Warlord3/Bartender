import 'package:bartender/models/Drinks.dart';

class Command {
  String command;
  Command({this.command});

  factory Command.fromJson(Map<String, dynamic> parsedJson) {
    return new Command(
        command: parsedJson['command'] == null ? "" : parsedJson['command']);
  }
}

class Status {
  int numberPumpsRunning;
  int drinkID;
  int progress;
  List<PumpStatus> pumpStatus;
  Status({
    this.numberPumpsRunning,
    this.drinkID,
    this.progress,
    this.pumpStatus,
  });
  Map<String, dynamic> toJson() => {
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
    );
  }
}

class PumpStatus {
  int id;
  int beverageID;
  int amount; //Amount that the Pumps already delivered
  int percent;
  PumpStatus({this.id, this.beverageID, this.amount, this.percent});
  factory PumpStatus.fromJson(Map<String, dynamic> json) => PumpStatus(
        id: json["ID"] == null ? -1 : json["ID"],
        beverageID: json["beverageID"] == null ? -1 : json["beverageID"],
        amount: json["amount"] == null ? 0 : json["amount"],
        percent: json["percent"] == null ? 0 : json["percent"],
      );
}

class Progress {
  int progress;
  Progress({
    this.progress,
  });

  factory Progress.fromJson(Map<String, dynamic> parsedJson) => Progress(
        progress: parsedJson['progress'] == null ? 0 : parsedJson['progress'],
      );
}

class PumpConfiguration {
  List<PumpConfig> configs = List<PumpConfig>.filled(
      16,
      PumpConfig(
        beverageID: -1,
        mlPerMinute: 0,
      ));
  PumpConfiguration({this.configs});
  PumpConfiguration.testData() {
    configs = List<PumpConfig>.generate(
        16,
        (index) => PumpConfig(
              beverageID: index,
              mlPerMinute: index * 10,
            ));
  }
  bool get configurated {
    return !configs
        .any((element) => element.beverageID == -1 && element.mlPerMinute == 0);
  }

  void setBeverageID(int index, int id) {
    configs[index].beverageID = id;
  }

  void setMlPerMinute(int index, int ml) {
    configs[index].mlPerMinute = ml;
  }

  factory PumpConfiguration.fromJson(Map<String, dynamic> parsedJson) =>
      PumpConfiguration(
        configs: parsedJson['config'] == null
            ? 0
            : (parsedJson['config'] as List)
                .map((i) => PumpConfig.fromJson(i))
                .toList(),
      );
  Map<String, dynamic> toJson() => {
        "command": "pump_config",
        "config": configs.map((e) => e.toJson()).toList(),
      };
}

class PumpConfig {
  int beverageID;
  int mlPerMinute;
  PumpConfig({
    this.beverageID,
    this.mlPerMinute,
  });
  factory PumpConfig.fromJson(Map<String, dynamic> parsedJson) => PumpConfig(
        beverageID:
            parsedJson['beverageID'] == null ? -1 : parsedJson['beverageID'],
        mlPerMinute:
            parsedJson['mlPerMinute'] == null ? 0 : parsedJson['mlPerMinute'],
      );
  Map<String, dynamic> toJson() => {
        "beverageID": beverageID,
        "mlPerMinute": mlPerMinute,
      };
}

class ConfigRequest {
  final String command = "pump_config_request";
  Map<String, dynamic> toJson() => {
        'command': command,
      };
}

class StartPump {
  List<int> IDs;
  StartPump({this.IDs});
  Map<String, dynamic> toJson() => {
        'command': "start_pump",
        'IDs': IDs,
      };
}

enum enPumpDirection {
  stop,
  forward,
  backward,
}

class StartPumpAll {
  enPumpDirection direction;
  StartPumpAll({this.direction});
  Map<String, dynamic> toJson() => {
        'command': "start_pump_all",
        'direction': direction,
      };
}

class StopPump {
  List<int> IDs;
  StopPump({this.IDs});
  Map<String, dynamic> toJson() => {
        'command': "stop_pump",
        'IDs': IDs,
      };
}

class StopPumpAll {
  Map<String, dynamic> toJson() => {
        'command': "stop_pump_all",
      };
}

class NewDrink {
  Drink drink;
  NewDrink({
    this.drink,
  });

  Map<String, dynamic> toJson() => {
        "command": "new_drink",
        "id": drink.id == null ? -1 : drink.id,
        "ingredients": drink.ingredients == null
            ? []
            : (drink.ingredients.map((i) => i.toJsonAsCommand()).toList()),
      };
}

class NewDrinkResponse {
  bool accepted;
  NewDrinkResponse({
    this.accepted,
  });

  factory NewDrinkResponse.fromJson(Map<String, dynamic> parsedJson) =>
      NewDrinkResponse(
        accepted:
            parsedJson['accepted'] == null ? false : parsedJson['accepted'],
      );
}
