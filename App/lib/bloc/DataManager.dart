import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bartender/bloc/AppStateManager.dart';
import 'package:bartender/models/CommunicationData.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:bartender/models/Websocket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DataManager with ChangeNotifier {
  List<Drink> allDrinks = [];
  List<Drink> favoriteDrinks = [];
  List<Drink> recentlyCreatedDrinks = [];
  static const int MAX_RECENTLY = 5;
  List<Beverage> beverages = [];

  PumpConfiguration pumpConfiguration = PumpConfiguration.testData();

  //Connection
  String ip = "192.168.178.74";
  bool get ipValid => ip.isNotEmpty;
  bool get isConnected => _controllerConnected;
  Websocket websocket;
  bool _controllerConnected = false;
  final String filename = "data.json";

  int drinkProgress = 0;
  bool drinkActive = false;
  bool drinkPause = false;

  //Save Process
  bool dataChanged = false;
  Timer saveTimer;

  DataManager({allDrinks, favoriteDrinks, recentlyCreatedDrinks, beverages}) {
    websocket = Websocket("ws://$ip:81",
        onConnectCallback: connected,
        onDisconnectCallback: disconnected,
        onDataCallback: callback);
  }

  DataManager.empty() {
    allDrinks = [];
    favoriteDrinks = [];
    recentlyCreatedDrinks = [];
    beverages = [];
  }

  Future<void> init() async {
    if (AppStateManager.initConnection) return;
    await connect();
    websocket.connect();

    AppStateManager.initConnection = true;
  }

  Future<bool> ping(String ip, Duration timeout) async {
    await Socket.connect(ip, 81, timeout: timeout).then((socket) {
      _controllerConnected = true;
      socket.destroy();
    }).catchError((error) {
      _controllerConnected = false;
    });
    return _controllerConnected;
  }

  Future<void> connect() async {
    if (!await ping('$ip', Duration(seconds: 5))) {
      Future.delayed(Duration(seconds: 10), connect);
      return;
    }

    Uri uri = Uri.http('$ip', 'data.json');
    final response = await http.get(uri).timeout(
      Duration(seconds: 2),
      onTimeout: () {
        _controllerConnected = false;
        return null;
      },
    );
    if (!_controllerConnected) return;
    if (response?.statusCode == 200) {
      DrinkSaveData saveData =
          DrinkSaveData.fromJson(jsonDecode(response.body));
      loadDataFromSaveData(saveData);
      print(jsonDecode(response.body));
    } else {
      print('Failed to load Data');
    }
  }

  loadDataFromSaveData(DrinkSaveData data) {
    this.allDrinks = data.drinks;
    this.beverages = data.beverages;
    this.favoriteDrinks = getFavoriteDrinks();
    this.recentlyCreatedDrinks = getRecentlyDrinks(data.recently);
  }

  void checkAndSortDrinks() {
    List<int> ids = [];
    for (Drink drink in this.allDrinks) {
      drink.possible = !drink.ingredients.any((element) => !this
          .pumpConfiguration
          .configs
          .map((e) => e.beverageID)
          .contains(element.beverage.id));
      if (ids.contains(drink.id)) {
        drink.id = _getNewDrinkID();
        save(false);
      }
      ids.add(drink.id);
    }

    allDrinks.sort((a, b) {
      if (b.possible) return 1;
      return -1;
    });
  }

  save([bool force = false]) async {
    saveTimer?.cancel();

    if (force && dataChanged) {
      await syncData();
    } else {
      saveTimer = Timer(Duration(seconds: 5), syncData);
    }
  }

  Future<bool> syncData() async {
    if (this.beverages.isEmpty && this.allDrinks.isEmpty)
      return false; // Skip save if no Data is available
    DrinkSaveData saveData = DrinkSaveData(
        beverages: this.beverages,
        drinks: this.allDrinks,
        recently: this.recentlyCreatedDrinks.map((e) => e.id).toList());

    Map jsonMap = saveData.toJson();
    String json = jsonEncode(jsonMap);

    http.MultipartRequest request =
        new http.MultipartRequest('POST', Uri.parse("http://$ip/upload"));
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        utf8.encode(json),
        filename: filename,
        contentType: MediaType(
          'application',
          'json',
          {'charset': 'utf-8'},
        ),
      ),
    );
    http.StreamedResponse response;
    try {
      response = await request.send();
    } catch (error) {
      print(error);
      return false;
    }
    if (response.statusCode != 200) {
      return false;
    }
    print("File uploaded");
    return true;
  }

  Map<String, dynamic> toJson() => {
        'drinks': allDrinks,
        'favorite': favoriteDrinks,
        'recently': recentlyCreatedDrinks,
        'beverages': beverages,
      };

  factory DataManager.fromJson(Map<String, dynamic> parsedJson) {
    return new DataManager(
      allDrinks: parsedJson['drinks'] == null ? null : parsedJson['drinks'],
      favoriteDrinks:
          parsedJson['favorite'] == null ? null : parsedJson['favorite'],
      recentlyCreatedDrinks:
          parsedJson['recently'] == null ? null : parsedJson['recently'],
      beverages:
          parsedJson['beverages'] == null ? null : parsedJson['beverages'],
    );
  }

  List<Drink> getFavoriteDrinks() {
    return this.allDrinks.where((element) => element.favorite).toList();
  }

  List<Drink> getRecentlyDrinks(List<int> recently) {
    return this
        .allDrinks
        .where((element) => recently.contains(element.id))
        .toList();
  }

  List<int> getRecentlyDrinkList() {
    return recentlyCreatedDrinks.map(((element) => element.id)).toList();
  }

  Beverage getBeverageByID(int id) {
    return this.beverages.firstWhere((element) => element.id == id,
        orElse: () => Beverage.none());
  }

  void removeDrink(Drink drink) {
    this.allDrinks.removeWhere((element) => element.id == drink.id);
    this.favoriteDrinks.removeWhere((element) => element.id == drink.id);
    this.recentlyCreatedDrinks.removeWhere((element) => element.id == drink.id);
    notifyListeners();
    dataChanged = true;
    save();
  }

  void changeFavorite(Drink drink, bool notify) {
    if (drink.favorite) {
      this.favoriteDrinks.removeWhere((element) => element.id == drink.id);
    } else {
      this.favoriteDrinks.insert(0, drink);
    }
    this
        .allDrinks[
            this.allDrinks.indexWhere((element) => element.id == drink.id)]
        .favorite = !drink.favorite;
    notifyListeners();
    dataChanged = true;
    save();
  }

  void saveDrink(Drink newDrink) {
    if (newDrink.id == -1) {
      newDrink.id = _getNewDrinkID();
      allDrinks.add(newDrink);
    } else {
      Drink oldDrink =
          allDrinks.firstWhere(((element) => element.id == newDrink.id));
      oldDrink.name = newDrink.name;
      oldDrink.amount = newDrink.amount;
      oldDrink.kcal = newDrink.kcal;
      oldDrink.percent = newDrink.percent;
      oldDrink.ingredients = newDrink.ingredients;
    }
    dataChanged = true;
    save();
  }

  void updateRecently(Drink drink) {
    if (recentlyCreatedDrinks.remove(drink)) {
    } else if (recentlyCreatedDrinks.length >= MAX_RECENTLY) {
      recentlyCreatedDrinks.removeLast();
    }
    recentlyCreatedDrinks.insert(0, drink);
  }

  int _getNewDrinkID() {
    return allDrinks.length != 0 ? allDrinks.last.id + 1 : 1;
  }

  void saveBeverage(Beverage newBeverage) {
    if (newBeverage.id == -1) {
      newBeverage.id = _getNewBeverageID();
      beverages.add(newBeverage);
    } else {
      Beverage oldBeverage =
          beverages.firstWhere(((element) => element.id == newBeverage.id));
      oldBeverage.name = newBeverage.name;
      oldBeverage.addition = newBeverage.addition;
      oldBeverage.kcal = newBeverage.kcal;
      oldBeverage.percent = newBeverage.percent;
    }
    notifyListeners();
    dataChanged = true;
    save();
  }

  int _getNewBeverageID() {
    return beverages.length != 0 ? beverages.last.id + 1 : 1;
  }

  bool pumpsConfigurated() {
    return this.pumpConfiguration.configurated;
  }

  void setInverted(int index, enMechanicalDirection direction) {
    this.pumpConfiguration.configs[index].mechanicalDirection = direction;
    setDirection(index, direction);
    notifyListeners();
  }

  void removeBeverage(Beverage beverage) {
    this.beverages.removeWhere((element) => element.id == beverage.id);
    dataChanged = true;
    save();
  }

  bool beverageInUse(Beverage beverage) {
    return allDrinks.any((drink) => drink.containsBeverage(beverage));
  }

  resetController() {
    String message = '{"command":"reset"';
    send(message);
  }

  startPump(int id, enPumpDirection pumpDirection) {
    StartPump command = StartPump(pumpID: id, pumpDirection: pumpDirection);
    send(command.toString());
  }

  stopPump(int id) {
    StopPump command = StopPump(pumpID: id);
    send(command.toString());
  }

  stopAllPumps() {
    StopPumpAll command = StopPumpAll();
    send(command.toString());
  }

  pauseDrink() {
    send(PauseDrink().toString());
  }

  continueDrink() {
    send(ContinueDrink().toString());
  }

  stopDrink() {
    send(StopDrink().toString());
  }

  sendDrink(Drink drink, {double scalling = 1.0}) {
    NewDrink command =
        NewDrink(drink: scalling == 1.0 ? drink : drink.scaleldCopy(scalling));
    send(command.toString());
    updateRecently(drink);
  }

  requestConfiguration() {
    send(ConfigRequest().toString());
  }

  sendConfiguration() {
    checkAndSortDrinks();
    send(this.pumpConfiguration.toString());
  }

  sendMilliliter(int index, int ml) {
    send(PumpMilliliter(index, ml).toString());
  }

  setDirection(int index, enMechanicalDirection direction) {
    send(Direction(direction, index).toString());
  }

  void send(dynamic data) {
    print("Websocket send:$data");
    websocket.send(data);
  }

  void connected() {
    print("Weboscket connected");
    notifyListeners();
  }

  void disconnected(String reason) {
    AppStateManager.showOverlayEntry(
        "Disconnected", AppStateManager.keyNavigator.currentState);

    print(reason);
    notifyListeners();
  }

  void callback(dynamic data) {
    var json = jsonDecode(data);
    print(data);
    String command = Command.fromJson(json).command;
    if (command == "connected") {
      requestConfiguration();
    } else if (command == "status") {
    } else if (command == "new_drink_response") {
      NewDrinkResponse response = NewDrinkResponse.fromJson(json);
      if (response.accepted) {
        drinkActive = true;
        this.drinkPause = false;
      } else {
        AppStateManager.showOverlayEntry("There went something wrong");
      }
    } else if (command == "drink_finished") {
      drinkActive = false;
      drinkProgress = 100;
      notifyListeners();
      AppStateManager.showOverlayEntry("Drink finnished");
      AppStateManager.removeProgressOverlay();
    } else if (command == "progress") {
      Progress progress = Progress.fromJson(json);
      if (progress.progress < 100 && progress.drinkActive) {
        AppStateManager.showProgressOverlay();
      }
      drinkProgress = progress.progress;
      drinkActive = progress.drinkActive;
      notifyListeners();
    } else if (command == "pump_config") {
      print("Read Configuration");
      this.pumpConfiguration = PumpConfiguration.fromJson(json);
      checkAndSortDrinks();
    } else if (command == "pause_drink_response") {
      PauseDrinkResponse response = PauseDrinkResponse.fromJson(json);
      if (response.paused) {
        this.drinkPause = true;
        notifyListeners();
      }
    } else if (command == "continue_drink_response") {
      ContinueDrinkResponse response = ContinueDrinkResponse.fromJson(json);
      if (response.continued) {
        this.drinkPause = false;
        notifyListeners();
      }
    } else if (command == "stop_drink_response") {
      StopDrinkResponse response = StopDrinkResponse.fromJson(json);
      if (response.stopped) {
        //TODO: do something with this information?
      }
    }
  }

  void testingMode(bool bool) {
    send(TestingMode(bool).toString());
  }
}
