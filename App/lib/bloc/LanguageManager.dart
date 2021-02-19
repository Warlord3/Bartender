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
    String data = "";
    for (LanguageEntry item in languageEntrys) {
      if (item.identifer == indetifier.toLowerCase()) {
        switch (language) {
          case Language.English:
            data = item.english;
            break;
          case Language.German:
            data = item.german;
            break;
        }
        break;
      }
    }
    return data;
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
  }
}

enum Language {
  German,
  English,
}

class LanguageEntry {
  String identifer = "";
  String english = "";
  String german = "";
  LanguageEntry(String identifer, String english, String german) {
    this.identifer = identifer;
    this.english = english;
    this.german = german;
  }
}
