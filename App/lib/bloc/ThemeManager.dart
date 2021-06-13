import 'package:bartender/bloc/LocalStorageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeManager(ThemeMode themeMode) {
    this._themeMode = themeMode;
  }
  getTheme() => _themeMode;
  setTheme(ThemeMode themeMode) {
    if (themeMode != this._themeMode) {
      _themeMode = themeMode;
      LocalStorageManager.storage.setInt("themeMode", themeMode.index);

      notifyListeners();
    }
  }
}

class Themes {
  /*
    Data for light theme
  */
  static final lightTheme = ThemeData(
    // ==== General
    brightness: Brightness.light,
    primaryColor: Colors.teal[700],
    accentColor: Colors.teal[700],
    backgroundColor: Colors.grey[200],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // ==== Specific Themes
    // == Button
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    // == Checkbox
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.resolveWith(
        (states) => Colors.white,
      ),
      fillColor: MaterialStateProperty.resolveWith(
        (states) => Colors.teal[700],
      ),
    ),
    // == Icon
    iconTheme: IconThemeData(
      color: Colors.grey[800],
    ),
    // == Card
    cardColor: Colors.grey[50],
    // == InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        fontSize: 18,
        color: Colors.teal[400],
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.teal[400],
        ),
      ),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.all(12),
    ),
    // == Text
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
      ),
      headline2: TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      headline3: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w400,
      ),
      headline4: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      headline5: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headline6: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      subtitle1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      subtitle2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyText1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      button: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      caption: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      overline: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
      ),
    ),
    // == Slider
    sliderTheme: SliderThemeData(
      trackShape: RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      activeTrackColor: Colors.cyan[800],
      activeTickMarkColor: Colors.cyan[800],
      thumbColor: Colors.cyan[400],
      showValueIndicator: ShowValueIndicator.never,
      valueIndicatorColor: Colors.cyan[400],
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    // == BottomNaviagtionBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedLabelStyle: TextStyle(
        color: Colors.grey[800],
      ),
      selectedItemColor: Colors.grey[800],
    ),
  );
  /*
    Data for dark theme
  */
  static final darkTheme = ThemeData(
    // ==== General
    brightness: Brightness.dark,
    primaryColor: Colors.teal[700],
    accentColor: Colors.teal[700],
    backgroundColor: Colors.grey[900],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // ==== Specific Themes
    // == Button
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.normal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    // == Checkbox
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.resolveWith(
        (states) => Colors.teal[700],
      ),
      fillColor: MaterialStateProperty.resolveWith(
        (states) => Colors.white,
      ),
    ),
    // == Icon
    iconTheme: IconThemeData(
      color: Colors.grey[200],
    ),
    // == Card
    cardColor: Colors.grey[600],
    // == InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        fontSize: 18,
        color: Colors.cyan[400],
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
        ),
      ),
      enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(),
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.all(12),
    ),
    // == Text
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
      ),
      headline2: TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      headline3: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w400,
      ),
      headline4: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      headline5: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headline6: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.15,
      ),
      subtitle1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      subtitle2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyText1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.3,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      button: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      caption: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      overline: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
      ),
    ),

    // == Slider
    sliderTheme: SliderThemeData(
      trackShape: RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      activeTrackColor: Colors.teal[800],
      activeTickMarkColor: Colors.teal[800],
      thumbColor: Colors.teal[400],
      showValueIndicator: ShowValueIndicator.never,
      valueIndicatorColor: Colors.teal[400],
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    // == BottomNaviagtionBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedLabelStyle: TextStyle(
        color: Colors.grey[300],
      ),
      selectedItemColor: Colors.grey[300],
    ),
  );
}
