import 'dart:convert';

import 'package:bartender/models/Drinks.dart';

class CommandBase {
  Map<String, dynamic> toJson() => throw UnimplementedError();
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Command {
  String command;
  Command({this.command});

  factory Command.fromJson(Map<String, dynamic> parsedJson) {
    return new Command(
        command: parsedJson['command'] == null ? "" : parsedJson['command']);
  }
}

class Status extends CommandBase {
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
  @override
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

class PumpStatus extends CommandBase {
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

class Progress extends CommandBase {
  int progress;
  bool drinkActive;
  Progress({this.progress, this.drinkActive});

  factory Progress.fromJson(Map<String, dynamic> parsedJson) => Progress(
        progress: parsedJson['progress'] == null ? 0 : parsedJson['progress'],
        drinkActive:
            parsedJson['drinkActiv'] == null ? false : parsedJson['drinkActiv'],
      );
}

class PumpConfiguration extends CommandBase {
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
  @override
  Map<String, dynamic> toJson() => {
        "command": "pump_config",
        "config": configs.map((e) => e.toJson()).toList(),
      };
}

class PumpConfig extends CommandBase {
  int beverageID = -1;
  int mlPerMinute = 0;
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
  @override
  Map<String, dynamic> toJson() => {
        "beverageID": beverageID,
        "mlPerMinute": mlPerMinute,
      };
}

class ConfigRequest extends CommandBase {
  final String command = "pump_config_request";
  Map<String, dynamic> toJson() => {
        'command': command,
      };
}

class StartPump extends CommandBase {
  int pumpID;
  enPumpDirection pumpDirection;
  StartPump({this.pumpID, this.pumpDirection});
  Map<String, dynamic> toJson() => {
        'command': "start_pump",
        'ID': pumpID,
        'direction': pumpDirection.index,
      };
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

enum enPumpDirection {
  stop,
  forward,
  backward,
}

class StartPumpAll extends CommandBase {
  enPumpDirection direction;
  StartPumpAll({this.direction});
  Map<String, dynamic> toJson() => {
        'command': "start_pump_all",
        'direction': direction,
      };
}

class StopPump extends CommandBase {
  int pumpID;
  StopPump({this.pumpID});
  @override
  Map<String, dynamic> toJson() => {
        'command': "stop_pump",
        'ID': pumpID,
      };
}

class StopPumpAll extends CommandBase {
  @override
  Map<String, dynamic> toJson() => {
        'command': "stop_pump_all",
      };
}

class PumpMilliliter extends CommandBase {
  final int pumpID;
  final int ml;
  PumpMilliliter(this.pumpID, this.ml);
  @override
  Map<String, dynamic> toJson() => {
        'command': "pump_milliliter",
        "ID": this.pumpID,
        "ml": this.ml,
      };
}

class NewDrink extends CommandBase {
  Drink drink;
  NewDrink({
    this.drink,
  });

  @override
  Map<String, dynamic> toJson() => {
        "command": "new_drink",
        "id": drink.id == null ? -1 : drink.id,
        "ingredients": drink.ingredients == null
            ? []
            : (drink.ingredients.map((i) => i.toJsonAsCommand()).toList()),
      };
}

class NewDrinkResponse extends CommandBase {
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

class TestingMode extends CommandBase {
  final bool enable;
  TestingMode(this.enable);

  @override
  Map<String, dynamic> toJson() =>
      {"command": "testing_mode", "enable": enable == null ? false : enable};
}
