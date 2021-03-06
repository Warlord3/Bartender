import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LanguageManager with ChangeNotifier {
  Language language = Language.English;

  List<LanguageEntry> languageEntrys = [];

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
    languageEntrys.add(new LanguageEntry("theme", "Theme", "Design"));
    languageEntrys.add(new LanguageEntry("light", "Light", "Hell"));
    languageEntrys.add(new LanguageEntry("dark", "Dark", "Dunkel"));
    languageEntrys.add(new LanguageEntry("system", "System", "System"));
    languageEntrys.add(new LanguageEntry("favorite", "Favorite", "Favoriten"));
    languageEntrys.add(new LanguageEntry("home", "Home", "Home"));
    languageEntrys.add(new LanguageEntry("drinks", "Drinks", "Drinks"));
    languageEntrys.add(new LanguageEntry("beverages", "Beverages", "Getränke"));
    languageEntrys.add(new LanguageEntry("beverage", "Beverage", "Getränk"));
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
    languageEntrys.add(
        new LanguageEntry("saved_drink", "Saved Drink", "Drink gespeichert"));
    languageEntrys
        .add(new LanguageEntry("drinkname", "Drinkname", "Drinkname"));
    languageEntrys.add(new LanguageEntry("drinkname_cant_be_empty",
        "Drinkname can't be empty", "Drinkname kann nicht leer sein"));
    languageEntrys.add(new LanguageEntry("pumpID", "Pump ID", "Pumpen ID"));
    languageEntrys
        .add(new LanguageEntry("ingredients", "Ingredients", "Zutaten"));
    languageEntrys.add(new LanguageEntry(
        "add_ingredient", "Add Ingredient", "Zutat hinzufügen"));
    languageEntrys.add(new LanguageEntry("add_ingredient_to_drink",
        "Add Ingredients to Drink", "Zutaten zum Trink hinzufügen"));
    languageEntrys.add(new LanguageEntry(
        "choose_beverage", "Choose Beverage", "Getränk auswählen"));
    languageEntrys.add(new LanguageEntry(
        "select_beverage", "Select Beverage", "Getränk auswählen"));
    languageEntrys.add(new LanguageEntry(
        "change_beverage", "Change Beverage", "Getränk ändern"));
    languageEntrys.add(new LanguageEntry("cancel", "Cancel", "Abbrechen"));
    languageEntrys.add(new LanguageEntry("save", "Save", "Speichern"));
    languageEntrys.add(new LanguageEntry(
        "mixing_drink", "Mixing Drink", "Getränk am zubereiten"));
    languageEntrys.add(new LanguageEntry("none", "None", "Keine"));
    languageEntrys.add(new LanguageEntry(
        "search_connection",
        "Search for Bartenders in local network",
        "Suche nach Bartendern im lokalen Netzwerk"));
    languageEntrys
        .add(new LanguageEntry("pump_testing", "Pump Testing", "Pumpen Test"));
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
