import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  static SharedPreferences storage;

  static Future<Null> init() async {
    storage = await SharedPreferences.getInstance();
  }
}
