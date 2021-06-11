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
  List<Beverage> beverages = [];

  PumpConfiguration pumpConfiguration;

  //Connection
  String ip = "192.168.178.74";
  bool get ipValid => ip.isNotEmpty;

  Websocket websocket;
  bool controllerConnected;
  final String filename = "data.json";

  int drinkProgress = 0;
  bool drinkActive = false;

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
    await Socket.connect(ip, 80, timeout: timeout).then((socket) {
      controllerConnected = true;
      socket.destroy();
    }).catchError((error) {
      controllerConnected = false;
    });
    return controllerConnected;
  }

  Future<void> connect() async {
    if (!await ping('192.168.178.74', Duration(seconds: 5))) {
      Future.delayed(Duration(seconds: 10), connect);
      return;
    }

    Uri uri = Uri.http('192.168.178.74', 'data.json');
    final response = await http.get(uri).timeout(
      Duration(seconds: 2),
      onTimeout: () {
        controllerConnected = false;
        return null;
      },
    );
    if (!controllerConnected) return;
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
        'userData',
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
    send(this.pumpConfiguration.toString());
  }

  sendMilliliter(int index, int ml) {
    send(PumpMilliliter(index, ml).toString());
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
      } else {
        AppStateManager.showOverlayEntry("There went something wrong");
      }
    } else if (command == "drink_finished") {
      drinkActive = false;
      drinkProgress = 100;
      notifyListeners();
      AppStateManager.showOverlayEntry("Drink finnished");
    } else if (command == "progress") {
      Progress progress = Progress.fromJson(json);
      drinkProgress = progress.progress;
      drinkActive = progress.drinkActive;
      notifyListeners();
    } else if (command == "pump_config") {
      print("Read Configuration");
      this.pumpConfiguration = PumpConfiguration.fromJson(json);
    }
  }

  void testingMode(bool bool) {
    send(TestingMode(bool).toString());
  }
}
