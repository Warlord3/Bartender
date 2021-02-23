import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LanguageManager with ChangeNotifier {
  Language language = Language.English;

  List<LanguageEntry> languageEntrys = List<LanguageEntry>();

  LanguageManager() {
    init();
  }
  getLanguage() => this.language;
  changeLanguage(Language language) {
    this.language = language;
    notifyListeners();
  }

  getData(String indetifier) {
    return languageEntrys
        .firstWhere((element) => element.identifer == indetifier,
            orElse: () => LanguageEntry("", indetifier, indetifier))
        .data[this.language.index];
  }

  /*
    Holds all the language entrys
  */
  init() {
    languageEntrys.add(new LanguageEntry("langauge", "Language", "Sprache"));
    languageEntrys
        .add(new LanguageEntry("dark_theme", "Dark Theme", "Dunkles Design"));
    languageEntrys.add(new LanguageEntry("favorite", "Favorite", "Favoriten"));
    languageEntrys.add(new LanguageEntry("home", "Home", "Home"));
    languageEntrys.add(new LanguageEntry("drinks", "Drinks", "Drinks"));
    languageEntrys.add(new LanguageEntry("beverages", "Beverages", "Getränke"));
    languageEntrys
        .add(new LanguageEntry("settings", "Settings", "Einstellungen"));
    languageEntrys.add(new LanguageEntry("controller_configuration",
        "Controller Configuration", "Controller Konfiguration"));
    languageEntrys.add(new LanguageEntry("beverage_configuration",
        "Bverage Configuration", "Getränke Konfiguration"));
    languageEntrys.add(
        new LanguageEntry("recent_drinks", "Recent Drinks", "Letzte Drinks"));
    languageEntrys.add(new LanguageEntry(
        "bartender_info", "Bartender Info", "Bartender Information"));
    languageEntrys
        .add(new LanguageEntry("connected", "Connected", "Verbunden"));
    languageEntrys.add(new LanguageEntry("problems", "Problems", "Probleme"));
    languageEntrys.add(new LanguageEntry("status", "Status", "Status"));
  }
}

enum Language {
  German,
  English,
}

class LanguageEntry {
  String identifer = "";
  List<String> data = ["", ""];
  LanguageEntry(String identifer, String english, String german) {
    this.identifer = identifer;
    this.data[Language.German.index] = german;
    this.data[Language.English.index] = english;
  }
}
