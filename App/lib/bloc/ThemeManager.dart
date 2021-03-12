import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeManager();
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
      overline: TextStyle(
        fontSize: 25,
        color: Colors.teal[400],
      ),
      subtitle1: TextStyle(
        fontSize: 18,
        color: Colors.grey[900],
      ),
      bodyText1: TextStyle(
        fontSize: 18,
        color: Colors.grey[900],
        fontWeight: FontWeight.normal,
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
          color: Colors.cyan[400],
        ),
      ),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.all(12),
    ),
    // == Text
    textTheme: TextTheme(
      overline: TextStyle(
        fontSize: 25,
        color: Colors.cyan[400],
      ),
      subtitle1: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
      bodyText1: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.normal,
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
