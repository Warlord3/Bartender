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
          create: (context) => DataManager(),
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

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("resumed");
        break;
      case AppLifecycleState.paused:
        print("paused");
        break;
      case AppLifecycleState.inactive:
        Provider.of<DataManager>(context, listen: false).save(true);
        print("inactive");
        break;
      case AppLifecycleState.detached:
        print("detached");
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<ThemeManager>(context);
    return MaterialApp(
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: themeMode.getTheme(),
      home: FutureBuilder(
          future: init(context),
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

  Future<bool> init(BuildContext context) async {
    await LocalStorageManager.init();
    await Provider.of<DataManager>(context, listen: false).init();

    return true;
  }
}
