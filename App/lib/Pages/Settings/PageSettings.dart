import 'dart:ui';

import 'package:bartender/Pages/Settings/LocalWidgets/ControllerConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bartender/bloc/ThemeManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeChangerProvider themeChangeProvider;
  LanguageManager languageManager;

  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context);
    themeChangeProvider = Provider.of<ThemeChangerProvider>(context);
    return Container(
        /*
        Table with settings page content
        */
        child: Table(
      columnWidths: {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(2),
      },
      children: [
        /*
          App Theme
        */
        TableRow(
          children: [
            TableCell(
              child: Center(
                child: Text(languageManager.getData("dark_theme")),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
            TableCell(
              child: Center(
                child: Switch(
                  value: themeChangeProvider.isDarkTheme(),
                  onChanged: (value) {
                    themeChangeProvider.toggleTheme();
                  },
                ),
              ),
            )
          ],
        ),
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
                    icon: Image.asset('icons/flags/png/de.png',
                        package: 'country_icons'),
                    onPressed: () {
                      languageManager.changeLanguage(Language.German);
                    },
                    tooltip: "German",
                  ),
                  IconButton(
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
                verticalAlignment: TableCellVerticalAlignment.middle),
            TableCell(
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.construction),
                  onPressed: () {
                    showGeneralDialog(
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
                  },
                ),
              ),
            ),
          ],
        )
      ],
    ));
  }
}
