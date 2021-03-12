import 'dart:convert';

import 'package:bartender/GlobalWidgets/NotifcationOverlay.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:bartender/models/PumpConfiguration.dart';
import 'package:bartender/models/Websocket.dart';
import 'package:flutter/material.dart';

import 'LocalStorageManager.dart';

class DataManager with ChangeNotifier {
  List<Drink> allDrinks = [];
  List<Drink> favoriteDrinks = [];
  List<Drink> recentlyCreatedDrinks = [];
  List<Beverage> beverages = [];

  PumpConfiguration pumpConfiguration;
  Websocket websocket;
  DataManager({allDrinks, favoriteDrinks, recentlyCreatedDrinks, beverages}) {
    websocket = Websocket("ws://192.168.178.74:81",
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

  void init() {
    testData();
    websocket.connect();
    return;
    String data = LocalStorageManager.storage.getString("DrinkData");
    if (data != null) {
      DrinkSaveData saveData = DrinkSaveData.fromJson(json.decode(data));
      this.allDrinks = saveData.drinks;
      this.favoriteDrinks =
          saveData.drinks.where((element) => element.favorite).toList();
      this.recentlyCreatedDrinks = this
          .allDrinks
          .where((element) => saveData.recently.contains(element.id))
          .toList();
      this.beverages = saveData.beverages;
    }
  }

  void save() {
    var temp = this.recentlyCreatedDrinks.map((e) => e.id).toList();
    DrinkSaveData save = DrinkSaveData(
        drinks: this.allDrinks, beverages: this.beverages, recently: temp);
    var json = save.toJson();
    String drinkData = jsonEncode(json);
    LocalStorageManager.storage.setString("DrinkData", drinkData);
  }

  void testData() {
    this.allDrinks = new List<Drink>.generate(
        40,
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
    this.recentlyCreatedDrinks = getRecentlyDrinks();
    this.pumpConfiguration = PumpConfiguration.testData();
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

  List<Drink> getRecentlyDrinks() {
    return this.allDrinks.where((element) => element.id < 3).toList();
  }

  Beverage getBeverageByID(int id) {
    return this.beverages.firstWhere((element) => element.id == id);
  }

  void removeDrink(Drink drink) {
    this.allDrinks.removeWhere((element) => element.id == drink.id);
    this.favoriteDrinks.removeWhere((element) => element.id == drink.id);
    this.recentlyCreatedDrinks.removeWhere((element) => element.id == drink.id);
    notifyListeners();
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
  }

  int _getNewDrinkID() {
    return allDrinks.last.id + 1;
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
  }

  int _getNewBeverageID() {
    return allDrinks.last.id + 1;
  }

  bool pumpsConfigurated() {
    return this.pumpConfiguration.configurated;
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
    String message = "new_drink";
    message += "\$";
    message += "${drink.id}";
    message += ";";
    for (Ingredient ingredient in drink.ingredients) {
      message += "${ingredient.beverage.id}";
      message += ":";
      message += "${(ingredient.amount * scalling).truncate()}";
      message += ";";
    }
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
    OverlayEntry entry = OverlayEntry(builder: (BuildContext context) {
      return FunkyNotification();
    });
    PageStateManager.keyNavigator.currentState.overlay.insert(entry);
    Future.delayed(Duration(seconds: 3), () {
      entry.remove();
    });

    print(reason);
    notifyListeners();
  }

  void callback(dynamic data) {}
}
