import 'dart:async';
import 'dart:convert';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/CommunicationData.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:bartender/models/PumpConfiguration.dart';
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
  final String url = "192.168.178.74";
  final String filename = "data.json";
  Websocket websocket;
  DataManager({allDrinks, favoriteDrinks, recentlyCreatedDrinks, beverages}) {
    websocket = Websocket("ws://$url:81",
        onConnectCallback: connected,
        onDisconnectCallback: disconnected,
        onDataCallback: callback);
  }
  int drinkProgress = 0;

  //Save Process
  bool dataChanged = false;
  Timer saveTimer;
  DataManager.empty() {
    allDrinks = [];
    favoriteDrinks = [];
    recentlyCreatedDrinks = [];
    beverages = [];
  }

  Future<void> init() async {
    Uri uri = Uri.http('192.168.178.74', 'data.json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      DrinkSaveData saveData =
          DrinkSaveData.fromJson(jsonDecode(response.body));
      this.allDrinks = saveData.drinks;
      this.beverages = saveData.beverages;
      this.recentlyCreatedDrinks = getRecentlyDrinks(saveData.recently);
      print(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('Failed to load Data');
    }
    websocket.connect();

    return;
  }

  save([bool force = false]) async {
    dataChanged = true;
    saveTimer?.cancel();

    if (force && dataChanged) {
      await syncData();
    } else {
      saveTimer = Timer(Duration(seconds: 5), syncData);
    }
  }

  Future<bool> syncData() async {
    DrinkSaveData saveData = DrinkSaveData(
        beverages: this.beverages,
        drinks: this.allDrinks,
        recently: this.recentlyCreatedDrinks.map((e) => e.id).toList());

    Map jsonMap = saveData.toJson();
    String json = jsonEncode(jsonMap);

    http.MultipartRequest request =
        new http.MultipartRequest('POST', Uri.parse("http://$url/upload"));
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
      return false;
    }
    if (response.statusCode != 200) {
      return false;
    }
    return true;
  }

  void testData() {
    this.allDrinks = new List<Drink>.generate(
        16,
        (i) => Drink(
            name: "Drink" + i.toString(),
            favorite: i % 2 == 0,
            id: i,
            ingredients: List<Ingredient>.generate(
                10,
                (index) => Ingredient(
                    amount: (index + 1) * 10,
                    beverage: Beverage(
                        name: "Colaasdddddddddddddddddddddd",
                        id: index,
                        addition: "Coca-Cola",
                        percent: 0.0,
                        kcal: 5)))));
    this.beverages = List<Beverage>.generate(
        this.allDrinks.length,
        (i) => Beverage(
            id: i,
            name: "Cola" + i.toString(),
            addition: "Coca-Cola",
            percent: i.toDouble(),
            kcal: i.toDouble()));
    this.recentlyCreatedDrinks = getRecentlyDrinks([1, 3, 4, 5, 8, 9]);
    this.pumpConfiguration = PumpConfiguration.testData();
    this.favoriteDrinks = getFavoriteDrinks();
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

  Beverage getBeverageByID(int id) {
    return this.beverages.firstWhere((element) => element.id == id);
  }

  void removeDrink(Drink drink) {
    this.allDrinks.removeWhere((element) => element.id == drink.id);
    this.favoriteDrinks.removeWhere((element) => element.id == drink.id);
    this.recentlyCreatedDrinks.removeWhere((element) => element.id == drink.id);
    notifyListeners();
    save();
  }

  void addDrink() {
    this.allDrinks.insert(
        0,
        Drink(
            name: "Drink",
            favorite: true,
            ingredients: List<Ingredient>.generate(
                10,
                (index) => Ingredient(
                    amount: index * 10 + 1,
                    beverage: Beverage(
                        name: "Colaasdddddddddddddddddddddd",
                        addition: "Coca-Cola",
                        percent: 0.0,
                        kcal: 5)))));
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
    save();
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
    save();
  }

  int _getNewBeverageID() {
    return beverages.length != 0 ? beverages.last.id + 1 : 1;
  }

  bool pumpsConfigurated() {
    return this.pumpConfiguration.configurated;
  }

  bool beverageDeleteable(Beverage beverage) {
    return true;
  }

  resetController() {
    String message = "reset";
    send(message);
  }

  startPump(List<int> ids) {
    String message = "start_pump";
    message += "\$";
    for (int id in ids) {
      message += "$id:";
    }
    send(message);
  }

  stopPump(int id) {
    send("$id");
  }

  stopAllPumps() {
    send("stop_pump_all");
  }

  sendDrink(Drink drink, {double scalling = 1.0}) {
    String message = jsonEncode(drink.toJsonAsCommand());
    send(message);
  }

  sendConfiguration() {
    String message = "pump_config";
    message += "\$";
    for (int i = 0; i < 16; i++) {
      message +=
          "$i:${pumpConfiguration.beverageIDs[i]}:${pumpConfiguration.mlPerMinute[i]}";
      if (i < 15) message += ";";
    }
    send(message);
  }

  void send(dynamic data) {
    websocket.send(data);
  }

  void connected() {
    notifyListeners();
  }

  void disconnected(String reason) {
    PageStateManager.showOverlayEntry(
        "Disconnected", PageStateManager.keyNavigator.currentState);

    print(reason);
    notifyListeners();
  }

  void callback(dynamic data) {
    if (data == "Connected") {
    } else {
      var json = jsonDecode(data);
      String command = Command.fromJson(json).command;
      if (command == "status") {
      } else if (command == "progress") {
        drinkProgress = Progress.fromJson(json).progress;
        notifyListeners();
      }
    }
  }
}
