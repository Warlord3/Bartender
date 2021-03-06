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
          ? null
          : (parsedJson['drinks'] as List)
              .map((i) => Drink.fromJson(i))
              .toList(),
      recently: parsedJson['recently'] == null
          ? null
          : List<int>.from(parsedJson['recently']),
      beverages: parsedJson['beverages'] == null
          ? null
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
        name: json["name"] == null ? null : json["name"],
        id: json["id"] == null ? null : json["id"],
        favorite: json["favorite"] == null ? null : json["favorite"],
        ingredients: json["ingredients"] == null
            ? null
            : (json['ingredients'] as List)
                .map((i) => Ingredient.fromJson(i))
                .toList(),
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
  int amount;
  Ingredient({this.beverage, this.amount});
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        beverage: json["beverage"] == null
            ? null
            : Beverage.fromJson(json["beverage"]),
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

  bool valid() {
    return name != "";
  }

  factory Beverage.fromJson(Map<String, dynamic> json) => Beverage(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        addition: json["addition"] == null ? null : json["addition"],
        percent: json["percent"] == null ? null : json["percent"],
        kcal: json["kcal"] == null ? null : json["kcal"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "addition": addition == null ? null : addition,
        "percent": percent == null ? null : percent,
        "kcal": kcal == null ? null : kcal,
      };
}
