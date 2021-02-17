import 'package:bartender/Pages/PageStart.dart';
import 'package:bartender/bloc/LocalStorage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Pages/PageRouter.dart';
import 'bloc/PageStateManager.dart';
import 'bloc/ThemeManager.dart';
import 'models/Drinks.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChangerProvider>(
          create: (context) => ThemeChangerProvider(ThemeMode.system),
        ),
        ChangeNotifierProvider<MainData>(
          create: (context) => LocalStorage.getDrinkData(),
        ),
        ChangeNotifierProvider<PageStateManager>(
          create: (context) => PageStateManager(),
        ),
      ],
      child: MainPage(),
    ));

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<ThemeChangerProvider>(context);
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
    await LocalStorage.init();
    return true;
  }
}
