enum DrinkType {
  AllDrinks,
  FavoriteDrinks,
  RecentlyDrinks,
}

class DrinkSaveData {
  List<Drink> drinks = [];
  List<int> recently = [];
  List<Beverage> beverages = [];

  DrinkSaveData({this.drinks, this.recently, this.beverages});

  Map<String, dynamic> toJson() => {
        'drinks': drinks,
        'recently': recently,
        'beverages': beverages,
      };

  factory DrinkSaveData.fromJson(Map<String, dynamic> parsedJson) {
    return new DrinkSaveData(
      drinks: parsedJson['drinks'] == null
          ? []
          : (parsedJson['drinks'] as List)
              .map((i) => Drink.fromJson(i))
              .toList(),
      recently: parsedJson['recently'] == null
          ? []
          : List<int>.from(parsedJson['recently']),
      beverages: parsedJson['beverages'] == null
          ? []
          : (parsedJson['beverages'] as List)
              .map((i) => Beverage.fromJson(i))
              .toList(),
    );
  }
}

class Drink {
  String name = "";
  int id = -1;
  int amount = 0;
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
    this.ingredients = [];
    this.ingredients.add(Ingredient.empty());
  }
  factory Drink.fromJson(Map<String, dynamic> json) => Drink(
        name: json["name"] == null ? "" : json["name"],
        id: json["id"] == null ? -1 : json["id"],
        favorite: json["favorite"] == null ? false : json["favorite"],
        ingredients: json["ingredients"] == null
            ? []
            : (json['ingredients'] as List)
                .map((i) => Ingredient.fromJson(i))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? "" : name,
        "id": id == null ? -1 : id,
        "favorite": favorite == null ? false : favorite,
        "ingredients": ingredients == null ? [] : ingredients,
      };

  Map<String, dynamic> toJsonAsCommand() => {
        "command": "new_drink",
        "id": id == null ? -1 : id,
        "ingredients": ingredients == null
            ? []
            : (ingredients.map((i) => i.toJsonAsCommand()).toList()),
      };

  ///Create a copy of the new scaled Drink
  Drink scaleldCopy(double scalling) {
    List<Ingredient> newIngredients;
    for (Ingredient ingredient in this.ingredients) {
      newIngredients.add(Ingredient(
          beverage: ingredient.beverage,
          amount: (ingredient.amount * scalling).truncate()));
    }
    Drink newDrink = Drink(
        id: this.id,
        favorite: this.favorite,
        name: this.name,
        ingredients: newIngredients);
    return newDrink;
  }

  ///Check if the current drink is valid
  bool valid() {
    return (name != "" && !ingredients.any((element) => !element.valid()));
  }

  ///Return lowest Amount of Ingredient in Drink
  ///
  ///If no Igredients return 0
  int lowestAmountIngredient() {
    return ingredients
            ?.reduce((curr, next) => curr.amount < next.amount ? curr : next)
            ?.amount ??
        0;
  }

  ///Get the lowest Amount of the Drink that is possible to mix
  int minDrinkAmount() {
    return amount ~/ lowestAmountIngredient();
  }

  ///get the scalling of the drink with the new Amount
  double scalling(double newAmount) {
    return newAmount / this.amount;
  }
}

class Ingredient {
  Beverage beverage;
  int amount;
  Ingredient({this.beverage, this.amount});
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        beverage: json["beverageID"] == null
            ? Beverage.empty()
            : Beverage.fromJson(json["beverageID"]),
        amount: json["amount"] == null ? 0 : json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "beverageID": beverage == null ? Beverage.empty() : beverage,
        "amount": amount == null ? 0 : amount,
      };
  Map<String, dynamic> toJsonAsCommand() => {
        "beverageID": beverage == null ? -1 : beverage.id,
        "amount": amount == null ? 0 : amount,
      };
  Ingredient.randomIngredient() {
    amount = 100;
    beverage = Beverage(name: "Cola", addition: "Coca-Cola", percent: 0.0);
  }
  Ingredient.empty() {
    this.amount = 0;
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
  Beverage({this.id, this.name, this.addition, this.percent, this.kcal});

  void update(Beverage newBeverage) {
    this.id = newBeverage.id;
    this.addition = newBeverage.addition;
    this.kcal = newBeverage.kcal;
    this.name = newBeverage.name;
    this.percent = newBeverage.percent;
  }

  Beverage.empty();

  Beverage copy() {
    return Beverage(
      id: this.id,
      addition: this.addition,
      name: this.name,
      percent: this.percent,
      kcal: this.kcal,
    );
  }

  bool valid() {
    return name != "";
  }

  factory Beverage.fromJson(Map<String, dynamic> json) => Beverage(
        id: json["id"] == null ? -1 : json["id"],
        name: json["name"] == null ? "null" : json["name"],
        addition: json["addition"] == null ? "null" : json["addition"],
        percent: json["percent"] == null ? 0 : json["percent"],
        kcal: json["kcal"] == null ? 0 : json["kcal"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? -1 : id,
        "name": name == null ? "null" : name,
        "addition": addition == "null" ? null : addition,
        "percent": percent < 0 ? null : percent,
        "kcal": kcal == null ? 0 : kcal,
      };
}
