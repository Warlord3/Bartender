import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bartender/Pages/Settings/LocalWidgets/BeverageConfiguration.dart';
import 'package:bartender/Pages/Settings/LocalWidgets/ControllerConfiguration.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/AppStateManager.dart';
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
  AppStateManager appStateManager;

  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context);
    themeChangeProvider = Provider.of<ThemeManager>(context);
    appStateManager = Provider.of<AppStateManager>(context, listen: false);
    dataManager = Provider.of<DataManager>(context, listen: false);
    return GestureDetector(
      onTap: () {
        print("tapped Settings GestureDetector");
        AppStateManager.settingsOverlayEntry?.remove();
      },
      child: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ThemeCheckbox(
                    languageManager: languageManager,
                    themeChangeProvider: themeChangeProvider,
                    value: "light",
                    themeMode: ThemeMode.light,
                  ),
                  ThemeCheckbox(
                    languageManager: languageManager,
                    themeChangeProvider: themeChangeProvider,
                    value: "dark",
                    themeMode: ThemeMode.dark,
                  ),
                  ThemeCheckbox(
                    languageManager: languageManager,
                    themeChangeProvider: themeChangeProvider,
                    value: "system",
                    themeMode: ThemeMode.system,
                  ),
                ],
              ),

              /*
                Language
              */

              Center(
                child: Text(languageManager.getData("langauge")),
              ),
              Center(
                  child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

              /*
                Controller Confgiuration
              */
              RowSetting(
                languageManager,
                "controller_configuration",
                Icons.construction,
                () async {
                  if (!dataManager.isConnected) {
                    AppStateManager.showOverlayEntry("Not Connected");
                    return;
                  }
                  appStateManager.pushedPage = enPushedPage.CONTROLLER_CONFIG;
                  dataManager.testingMode(true);

                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ControllerConfiguration(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              /*
                Beverage Configuration
              */
              RowSetting(
                languageManager,
                "beverage_configuration",
                Icons.local_gas_station,
                () {
                  appStateManager.pushedPage = enPushedPage.BEVERAGE_CONFIG;
                  AppStateManager.keyNavigator.currentState.push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          BeverageConfiguration(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
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
                },
                child: Text("Reset Controller"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RowSetting extends StatelessWidget {
  final IconData iconData;
  final String textData;
  final Function onPressed;
  final LanguageManager languageManager;
  RowSetting(
      this.languageManager, this.textData, this.iconData, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 50,
        ),
        Flexible(
          flex: 8,
          fit: FlexFit.loose,
          child: Container(
            width: double.infinity,
            child: Text(
              languageManager.getData(textData),
            ),
          ),
        ),
        Flexible(
          flex: 4,
          fit: FlexFit.tight,
          child: IconButton(
            splashRadius: 25,
            icon: Icon(this.iconData),
            onPressed: this.onPressed,
          ),
        ),
      ],
    );
  }
}

class ControllerConfig extends StatelessWidget {
  final LanguageManager languageManager;
  final DataManager dataManager;
  ControllerConfig(this.languageManager, this.dataManager);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: Text(
            languageManager.getData("controller_configuration"),
          ),
        ),
        Center(
          child: IconButton(
            splashRadius: 25,
            icon: Icon(Icons.construction),
            onPressed: () async {},
          ),
        ),
      ],
    );
  }
}

class LanguageSelector extends StatefulWidget {
  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        key: _key,
        splashRadius: 25,
        icon: Image.asset('icons/flags/png/gb.png', package: 'country_icons'),
        onPressed: () {
          RenderBox renderBox = context.findRenderObject();
          var size = renderBox.size;
          var offset = renderBox.localToGlobal(Offset.zero);
          print(size.height);
          print(offset.dy);
          AppStateManager.settingsOverlayEntry = OverlayEntry(
            builder: (context) => Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Material(
                child: Text("asdfas"),
              ),
            ),
          );

          Overlay.of(context).insert(AppStateManager.settingsOverlayEntry);
        },
        tooltip: "English",
      ),
    );
  }
}

class ThemeCheckbox extends StatelessWidget {
  const ThemeCheckbox(
      {Key key,
      @required this.languageManager,
      @required this.themeChangeProvider,
      @required this.value,
      @required this.themeMode})
      : super(key: key);

  final LanguageManager languageManager;
  final ThemeManager themeChangeProvider;
  final String value;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          languageManager.getData(value),
        ),
        Checkbox(
          value: themeChangeProvider.getTheme() == themeMode,
          onChanged: (value) {
            themeChangeProvider.setTheme(themeMode);
          },
        ),
      ],
    );
  }
}
