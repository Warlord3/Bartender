import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ThemeChangerProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeChangerProvider();
  getTheme() => _themeMode;
  setTheme(ThemeMode themeMode) {
    if (themeMode != this._themeMode) {
      _themeMode = themeMode;
      notifyListeners();
    }
  }
}

class Themes {
  /*
    Data for light theme
  */
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.red,
    accentColor: Colors.white,
    backgroundColor: Colors.white,
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  /*
    Data for dark theme
  */
  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      accentColor: Colors.lightBlue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardColor: Colors.grey[600],
      buttonColor: Color(0XFFF8D320),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(fontSize: 18, color: Colors.blue),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12),
      ),
      textTheme: TextTheme(
          overline: TextStyle(
            fontSize: 25,
            color: Colors.blue,
          ),
          subtitle1: TextStyle(
            fontSize: 18,
            color: Colors.blue,
          )),
      sliderTheme: SliderThemeData(),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.normal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      backgroundColor: Color(0xff000000));
}
