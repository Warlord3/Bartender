import 'dart:convert';

import 'package:bartender/bloc/LocalStorage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainData with ChangeNotifier {
  List<Drink> allDrinks = List<Drink>();
  List<Drink> favoriteDrinks = List<Drink>();
  List<Drink> recentlyCreatedDrinks = List<Drink>();
  List<Beverage> beverages = List<Beverage>();

  MainData({allDrinks, favoriteDrinks, recentlyCreatedDrinks, beverages});
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
                    amount: index.toDouble(),
                    beverage: Beverage(name: "Colaasdddddddddddddddddddddd", addition: "Coca-Cola", percent: 0.0, kcal: 5)))));
    this.beverages = List<Beverage>.generate(
        this.allDrinks.length, (i) => Beverage(name: "Cola" + i.toString(), addition: "Coca-Cola", percent: i.toDouble(), kcal: i.toDouble()));
    this.recentlyCreatedDrinks = getRecentlyDrinks();
  }

  MainData.empty() {
    allDrinks = List<Drink>();
    favoriteDrinks = List<Drink>();
    recentlyCreatedDrinks = List<Drink>();
    beverages = List<Beverage>();
  }

  void init() {
    String data = LocalStorage.storage.getString("DrinkData");
    if (data != null) {
      DrinkSaveData saveData = DrinkSaveData.fromJson(json.decode(data));
      this.allDrinks = saveData.drinks;
      this.favoriteDrinks = saveData.drinks.where((element) => element.favorite).toList();
      this.recentlyCreatedDrinks = this.allDrinks.where((element) => saveData.recently.contains(element.id)).toList();
      this.beverages = saveData.beverages;
    }
    testData();
    save();
  }

  void save() {
    var temp = this.recentlyCreatedDrinks.map((e) => e.id).toList();
    DrinkSaveData save = DrinkSaveData(drinks: this.allDrinks, beverages: this.beverages, recently: temp);
    var json = save.toJson();
    String drinkData = jsonEncode(json);
    LocalStorage.storage.setString("DrinkData", drinkData);
  }

  Map<String, dynamic> toJson() => {
        'drinks': allDrinks,
        'favorite': favoriteDrinks,
        'recently': recentlyCreatedDrinks,
        'beverages': beverages,
      };

  factory MainData.fromJson(Map<String, dynamic> parsedJson) {
    return new MainData(
      allDrinks: parsedJson['drinks'] == null ? null : parsedJson['drinks'],
      favoriteDrinks: parsedJson['favorite'] == null ? null : parsedJson['favorite'],
      recentlyCreatedDrinks: parsedJson['recently'] == null ? null : parsedJson['recently'],
      beverages: parsedJson['beverages'] == null ? null : parsedJson['beverages'],
    );
  }

  List<Drink> getFavoriteDrinks() {
    return this.allDrinks.where((element) => element.favorite).toList();
  }

  List<Drink> getRecentlyDrinks() {
    return this.allDrinks.where((element) => element.id < 3).toList();
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
                    amount: index.toDouble(),
                    beverage: Beverage(name: "Colaasdddddddddddddddddddddd", addition: "Coca-Cola", percent: 0.0, kcal: 5)))));
  }

  void changeFavorite(Drink drink, bool notify) {
    if (drink.favorite) {
      this.favoriteDrinks.removeWhere((element) => element.id == drink.id);
    } else {
      this.favoriteDrinks.insert(0, drink);
    }
    this.allDrinks[this.allDrinks.indexWhere((element) => element.id == drink.id)].favorite = !drink.favorite;
    notifyListeners();
  }

  void saveDrink(Drink newDrink) {
    if (newDrink.id == -1) {
      newDrink.id = _getNewDrinkID();
      allDrinks.add(newDrink);
    } else {
      Drink oldDrink = allDrinks.firstWhere(((element) => element.id == newDrink.id));
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
      Beverage oldBeverage = beverages.firstWhere(((element) => element.id == newBeverage.id));
      oldBeverage.name = newBeverage.name;
      oldBeverage.addition = newBeverage.addition;
      oldBeverage.kcal = newBeverage.kcal;
      oldBeverage.percent = newBeverage.percent;
    }
  }

  int _getNewBeverageID() {
    return allDrinks.last.id + 1;
  }
}

enum DrinkType {
  AllDrinks,
  FavoriteDrinks,
  RecentlyDrinks,
}

class DrinkSaveData {
  List<Drink> drinks = List<Drink>();
  List<int> recently = List<int>();
  List<Beverage> beverages = List<Beverage>();

  DrinkSaveData({this.drinks, this.recently, this.beverages});

  Map<String, dynamic> toJson() => {
        'drinks': drinks,
        'recently': recently,
        'beverages': beverages,
      };

  factory DrinkSaveData.fromJson(Map<String, dynamic> parsedJson) {
    return new DrinkSaveData(
      drinks: parsedJson['drinks'] == null ? null : (parsedJson['drinks'] as List).map((i) => Drink.fromJson(i)).toList(),
      recently: parsedJson['recently'] == null ? null : List<int>.from(parsedJson['recently']),
      beverages: parsedJson['beverages'] == null ? null : (parsedJson['beverages'] as List).map((i) => Beverage.fromJson(i)).toList(),
    );
  }
}

class Drink {
  String name = "";
  int id = -1;
  double amount = 0.0;
  double percent = 0.0;
  double kcal = 0.0;
  List<Ingredient> ingredients;
  bool favorite = false;

  Drink({this.name, this.id, this.favorite, this.ingredients}) {
    updateStats();
  }
  void updateStats() {
    this.percent = 0;
    this.amount = 0;
    this.kcal = 0;
    this.percent = 0;
    for (var ingredient in this.ingredients) {
      this.percent += ingredient.beverage.percent * ingredient.amount;
      this.amount += ingredient.amount;
      this.kcal += ingredient.beverage.kcal;
    }
    this.percent /= this.amount;
  }

  Drink.newDrink() {
    this.name = "";
    this.id = -1;
    this.ingredients = List<Ingredient>();
    this.ingredients.add(Ingredient.empty());
  }
  factory Drink.fromJson(Map<String, dynamic> json) => Drink(
        name: json["name"] == null ? null : json["name"],
        id: json["id"] == null ? null : json["id"],
        favorite: json["favorite"] == null ? null : json["favorite"],
        ingredients: json["ingredients"] == null ? null : (json['ingredients'] as List).map((i) => Ingredient.fromJson(i)).toList(),
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "id": id == null ? null : id,
        "favorite": favorite == null ? null : favorite,
        "ingredients": ingredients == null ? null : ingredients,
      };

  bool valid() {
    return (name != "" && !ingredients.any((element) => !element.valid()));
  }
}

class Ingredient {
  Beverage beverage;
  double amount;
  Ingredient({this.beverage, this.amount});
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        beverage: json["beverage"] == null ? null : Beverage.fromJson(json["beverage"]),
        amount: json["amount"] == null ? 0 : json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "beverage": beverage == null ? null : beverage,
        "amount": amount == null ? 0 : amount,
      };
  Ingredient.randomIngredient() {
    amount = 100;
    beverage = Beverage(name: "Cola", addition: "Coca-Cola", percent: 0.0);
  }
  Ingredient.empty() {
    this.amount = 0.0;
    this.beverage = Beverage.empty();
  }

  bool valid() {
    return (beverage.valid() && amount > 0.0);
  }
}

class Beverage {
  String name = "";
  int id = -1;
  String addition = "";
  double percent = 0.0;
  double kcal = 0.0;
  bool get nonAlcoholic => percent == 0.0;
  Beverage({this.name, this.addition, this.percent, this.kcal});

  void update(Beverage newBeverage) {
    this.addition = newBeverage.addition;
    this.kcal = newBeverage.kcal;
    this.name = newBeverage.name;
    this.percent = newBeverage.percent;
  }

  Beverage.empty();

  bool valid() {
    return name != "";
  }

  factory Beverage.fromJson(Map<String, dynamic> json) => Beverage(
        name: json["name"] == null ? null : json["name"],
        addition: json["addition"] == null ? null : json["addition"],
        percent: json["percent"] == null ? null : json["percent"],
        kcal: json["kcal"] == null ? null : json["kcal"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "addition": addition == null ? null : addition,
        "percent": percent == null ? null : percent,
        "kcal": kcal == null ? null : kcal,
      };
}
