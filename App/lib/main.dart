import 'package:bartender/Pages/Connection/PageConnection.dart';
import 'package:bartender/Pages/Start/PageStart.dart';
import 'package:bartender/bloc/LocalStorageManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Pages/PageRouter.dart';
import 'bloc/DataManager.dart';
import 'bloc/AppStateManager.dart';
import 'bloc/ThemeManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageManager.init();

  ThemeMode themeMode = ThemeMode.dark;
  if (LocalStorageManager.storage.containsKey("themeMode")) {
    themeMode =
        ThemeMode.values[LocalStorageManager.storage.getInt("themeMode")];
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeManager>(
        create: (context) => ThemeManager(themeMode),
      ),
      ChangeNotifierProvider<DataManager>(
        create: (context) => DataManager(),
      ),
      ChangeNotifierProvider<LanguageManager>(
        create: (context) => LanguageManager(),
      ),
    ],
    child: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  bool hasIP = false;
  ThemeManager themeMode;
  DataManager dataManager;
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
    themeMode = Provider.of<ThemeManager>(context);
    dataManager = Provider.of<DataManager>(context, listen: false);

    return MaterialApp(
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: themeMode.getTheme(),
      home: getPage(),
    );
  }

  Widget getPage() {
    if (!AppStateManager.initIP) {
      return FutureBuilder(
        future: init(context),
        builder: (buidContext, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              return PageRouter();
            } else {
              return ConnectionPage();
            }
          }
          return StartPage();
        },
      );
    } else {
      return PageRouter();
    }
  }

  Future<bool> init(BuildContext context) async {
    if (LocalStorageManager.storage.containsKey("controllerIP")) {
      String controllerIp =
          LocalStorageManager.storage.getString("controllerIP");
      Provider.of<DataManager>(context, listen: false).ip = controllerIp;

      AppStateManager.initIP = true;
      await Provider.of<DataManager>(context, listen: false).init();
      return true;
    }
    return false;
  }
}
