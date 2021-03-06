import 'package:bartender/bloc/DataManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  static SharedPreferences storage;

  static Future<Null> init() async {
    storage = await SharedPreferences.getInstance();
  }

  static DataManager getDrinkData() {
    DataManager data = DataManager();
    data.init();

    data ??= DataManager.empty();
    return data;
  }
}
