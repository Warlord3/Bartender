import 'package:bartender/models/Drinks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences storage;

  static Future<Null> init() async {
    storage = await SharedPreferences.getInstance();
  }

  static MainData getDrinkData() {
    MainData data = MainData();
    data.init();

    data ??= MainData.empty();
    return data;
  }
}
