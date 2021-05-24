import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bartender/Pages/Settings/LocalWidgets/BeverageConfiguration.dart';
import 'package:bartender/Pages/Settings/LocalWidgets/ControllerConfiguration.dart';
import 'package:bartender/Pages/Settings/LocalWidgets/PumpTestPage.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bartender/bloc/ThemeManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:file_picker/file_picker.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeManager themeChangeProvider;
  LanguageManager languageManager;
  DataManager dataManager;

  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context);
    themeChangeProvider = Provider.of<ThemeManager>(context);
    dataManager = Provider.of<DataManager>(context, listen: false);
    return Container(
        /*
        Table with settings page content
        */
        child: Material(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                languageManager.getData("theme"),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Center(
            child: Table(
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              textBaseline: TextBaseline.alphabetic,
              defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
              children: [
                TableRow(children: [
                  Center(
                    child: Text(
                      languageManager.getData("light"),
                    ),
                  ),
                  Center(
                    child: Text(
                      languageManager.getData("dark"),
                    ),
                  ),
                  Center(
                    child: Text(
                      languageManager.getData("system"),
                    ),
                  ),
                ]),
                TableRow(
                  children: [
                    Checkbox(
                      value: themeChangeProvider.getTheme() == ThemeMode.light,
                      onChanged: (value) {
                        themeChangeProvider.setTheme(ThemeMode.light);
                      },
                    ),
                    Checkbox(
                      value: themeChangeProvider.getTheme() == ThemeMode.dark,
                      onChanged: (value) {
                        themeChangeProvider.setTheme(ThemeMode.dark);
                      },
                    ),
                    Checkbox(
                      value: themeChangeProvider.getTheme() == ThemeMode.system,
                      onChanged: (value) {
                        themeChangeProvider.setTheme(ThemeMode.system);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Table(
            columnWidths: {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(2),
            },
            textBaseline: TextBaseline.alphabetic,
            children: [
              /*
                Language
              */
              TableRow(
                children: [
                  TableCell(
                    child: Center(
                      child: Text(languageManager.getData("langauge")),
                    ),
                    verticalAlignment: TableCellVerticalAlignment.middle,
                  ),
                  TableCell(
                    child: Center(
                        child: Row(
                      children: [
                        IconButton(
                          splashRadius: 25,
                          icon: Image.asset('icons/flags/png/de.png',
                              package: 'country_icons'),
                          onPressed: () {
                            languageManager.changeLanguage(Language.German);
                          },
                          tooltip: "German",
                        ),
                        IconButton(
                          splashRadius: 25,
                          icon: Image.asset('icons/flags/png/gb.png',
                              package: 'country_icons'),
                          onPressed: () {
                            languageManager.changeLanguage(Language.English);
                          },
                          tooltip: "English",
                        )
                      ],
                    )),
                  ),
                ],
              ),
              /*
                Controller Confgiuration
              */
              TableRow(
                children: [
                  TableCell(
                    child: Center(
                      child: Text(
                        languageManager.getData("controller_configuration"),
                      ),
                    ),
                    verticalAlignment: TableCellVerticalAlignment.middle,
                  ),
                  TableCell(
                    child: Center(
                      child: IconButton(
                        splashRadius: 25,
                        icon: Icon(Icons.construction),
                        onPressed: () async {
                          if (!dataManager.controllerConnected) {
                            AppStateManager.showOverlayEntry("Not Connected");
                            return;
                          }
                          await showGeneralDialog(
                            barrierDismissible: true,
                            barrierLabel: '',
                            barrierColor: Colors.black38,
                            transitionDuration: Duration(milliseconds: 200),
                            pageBuilder: (ctx, anim1, anim2) =>
                                ControllerConfiguration(),
                            transitionBuilder: (ctx, anim1, anim2, child) =>
                                BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: anim1.value * 3,
                                sigmaY: anim1.value * 3,
                              ),
                              child: FadeTransition(
                                child: child,
                                opacity: anim1,
                              ),
                            ),
                            context: context,
                          );
                          dataManager.sendConfiguration();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              /*
              Pump PumpTesting
              */
              TableRow(
                children: [
                  TableCell(
                    child: Center(
                      child: Text(
                        languageManager.getData("pump_testing"),
                      ),
                    ),
                    verticalAlignment: TableCellVerticalAlignment.middle,
                  ),
                  TableCell(
                    child: Center(
                      child: IconButton(
                        splashRadius: 25,
                        icon: Icon(Icons.local_gas_station),
                        onPressed: () {
                          if (!dataManager.controllerConnected) {
                            AppStateManager.showOverlayEntry("Not Connected");
                            return;
                          }
                          if (dataManager.drinkActive) {
                            AppStateManager.showOverlayEntry(
                                "Drink in progress");
                            return;
                          }
                          AppStateManager.pushedPage = true;
                          dataManager.testingMode(true);
                          AppStateManager.keyNavigator.currentState.push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      PumpTestPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              /*
                Beverage Configuration
              */
              TableRow(
                children: [
                  TableCell(
                    child: Center(
                      child: Text(
                        languageManager.getData("beverage_configuration"),
                      ),
                    ),
                    verticalAlignment: TableCellVerticalAlignment.middle,
                  ),
                  TableCell(
                    child: Center(
                      child: IconButton(
                        splashRadius: 25,
                        icon: Icon(Icons.local_gas_station),
                        onPressed: () {
                          AppStateManager.pushedPage = true;

                          AppStateManager.keyNavigator.currentState.push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      BeverageConfiguration(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () async {
              FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ["json"]).then((value) {
                if (value != null) {
                  File file = File(value.paths.first);
                  Map<String, dynamic> json =
                      jsonDecode(file.readAsStringSync());
                  if (json.containsKey("drinks") &&
                      json.containsKey("recently") &&
                      json.containsKey("beverages")) {
                    DrinkSaveData data = DrinkSaveData.fromJson(json);
                    dataManager.loadDataFromSaveData(data);
                    AppStateManager.showOverlayEntry("BackupLoaded");
                    dataManager.syncData();
                  } else {
                    AppStateManager.showOverlayEntry("Couldn't read File");
                  }
                }
              });
            },
            child: Text("Load Config"),
          ),
          ElevatedButton(
            onPressed: () async {
              FilePicker.platform.getDirectoryPath().then((path) {
                if (path != null) {
                  DrinkSaveData data = DrinkSaveData();
                  data.beverages = dataManager.beverages;
                  data.drinks = dataManager.allDrinks;
                  data.recently = dataManager.getRecentlyDrinkList();
                  DateTime now = new DateTime.now();
                  print(
                      "$path/MyBartender_${now.day.toString()}_${now.month.toString()}_${now.year.toString()}.json");
                  File file = File(
                      "$path/MyBartender_${now.day.toString()}_${now.month.toString()}_${now.year.toString()}.json");
                  file.writeAsString(jsonEncode(data.toJson()));
                }
              });
            },
            child: Text("Save Config"),
          ),
          ElevatedButton(
            onPressed: () async {
              await showGeneralDialog(
                barrierDismissible: true,
                barrierLabel: '',
                barrierColor: Colors.black38,
                transitionDuration: Duration(milliseconds: 200),
                pageBuilder: (ctx, anim1, anim2) => Center(
                    child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Text(
                          "Are you sure that you want to reset the controller?",
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            dataManager.resetController();
                            Navigator.of(ctx).pop();
                          },
                          child: Text(
                            "Yes",
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text(
                            "No",
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: anim1.value * 3,
                    sigmaY: anim1.value * 3,
                  ),
                  child: FadeTransition(
                    child: child,
                    opacity: anim1,
                  ),
                ),
                context: context,
              );
            },
            child: Text("Reset Controller"),
          ),
        ],
      ),
    ));
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
