import 'package:bartender/Pages/Start/PageStart.dart';
import 'package:bartender/bloc/LocalStorageManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Pages/PageRouter.dart';
import 'bloc/DataManager.dart';
import 'bloc/PageStateManager.dart';
import 'bloc/ThemeManager.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>(
          create: (context) => ThemeManager(),
        ),
        ChangeNotifierProvider<DataManager>(
          create: (context) => LocalStorageManager.getDrinkData(),
        ),
        ChangeNotifierProvider<PageStateManager>(
          create: (context) => PageStateManager(),
        ),
        ChangeNotifierProvider<LanguageManager>(
          create: (context) => LanguageManager(),
        ),
      ],
      child: MainPage(),
    ));

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<ThemeManager>(context);
    return MaterialApp(
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: themeMode.getTheme(),
      home: FutureBuilder(
          future: getSharedPreferences(),
          builder: (context, snapshot) {
            Widget child;
            if (snapshot.connectionState == ConnectionState.done) {
              child = PageRouter();
            } else {
              child = StartPage();
            }
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: child,
            );
          }),
    );
  }

  Future<bool> getSharedPreferences() async {
    await LocalStorageManager.init();
    return true;
  }
}
