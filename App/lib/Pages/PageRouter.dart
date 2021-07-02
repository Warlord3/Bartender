import 'package:bartender/Pages/Drinks/PageDrinks.dart';
import 'package:bartender/Pages/Favorite/PageFavorite.dart';
import 'package:bartender/Pages/Beverage/PageBeverage.dart';
import 'package:bartender/Pages/Settings/PageSettings.dart';
import 'package:bartender/Pages/Home/PageHome.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/AppStateManager.dart';
import 'package:bartender/bloc/ThemeManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bartender/bloc/LanguageManager.dart';

import 'Start/PageStart.dart';

class PageRouter extends StatefulWidget {
  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {
  LanguageManager languageManager;
  ThemeManager themeChangeProvider;
  AppStateManager appStateManager;

  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context);
    themeChangeProvider = Provider.of<ThemeManager>(context);
    appStateManager = Provider.of<AppStateManager>(context);
    AppStateManager.screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppBarTitle()),
        leading: appStateManager.pagePushed
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  checkPushedPage(context);
                })
            : null,
      ),
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () async {
          print("pop from return");
          return Future.value(!checkPushedPage(context));
        },
        child: SafeArea(
          child: Navigator(
            key: AppStateManager.keyNavigator,
            initialRoute: "Home",
            onGenerateRoute: (RouteSettings settings) {
              Widget page = Container();
              switch (settings.name) {
                case "Home":
                  page = HomePage();
                  break;
                case "Favorite":
                  page = FavoritePage();
                  break;
                case "Drinks":
                  page = DrinksPage();
                  break;
                case "Beverages":
                  page = BeveragePage();
                  break;
                case "Settings":
                  page = SettingsPage();
                  break;
                default:
                  page = StartPage();
                  break;
              }
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                transitionDuration: Duration(milliseconds: 500),
                settings: settings,
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              color: Colors.orange,
            ),
            label: languageManager.getData("home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_outline,
              color: Colors.red,
            ),
            label: languageManager.getData("favorite"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_drink_outlined,
              color: Colors.greenAccent[400],
            ),
            label: languageManager.getData("drinks"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
              color: themeChangeProvider.getTheme() == ThemeMode.light
                  ? Colors.grey[800]
                  : Colors.grey[200],
            ),
            label: languageManager.getData("settings"),
          )
        ],
        onTap: _pageSelect,
        currentIndex: AppStateManager.lastPageIndex,
        unselectedItemColor: Colors.transparent,
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(fontSize: 15),
      ),
    );
  }

  ///Check if current Page can be pop and sends data based on current pushed Page
  ///
  ///return: bool
  bool checkPushedPage(BuildContext context) {
    if (AppStateManager.keyNavigator.currentState.canPop() &&
        appStateManager.pagePushed) {
      DataManager dataManager =
          Provider.of<DataManager>(context, listen: false);
      switch (appStateManager.pushedPage) {
        case enPushedPage.NONE:
          break;
        case enPushedPage.BEVERAGE_CONFIG:
          dataManager.save(false);
          break;
        case enPushedPage.CONTROLLER_CONFIG:
          dataManager.stopAllPumps();
          dataManager.sendConfiguration();
          break;
        default:
      }
      AppStateManager.keyNavigator.currentState.pop();

      appStateManager.pushedPage = enPushedPage.NONE;
      return true;
    }
    return false;
  }

  void _pageSelect(int value) {
    setState(() {
      if (AppStateManager.lastPageIndex != value) {
        switch (value) {
          case 0:
            AppStateManager.keyNavigator.currentState.pushNamed("Home");
            break;
          case 1:
            AppStateManager.keyNavigator.currentState.pushNamed("Favorite");
            break;
          case 2:
            AppStateManager.keyNavigator.currentState.pushNamed("Drinks");
            break;
          case 3:
            AppStateManager.keyNavigator.currentState.pushNamed("Settings");
            break;
          default:
            AppStateManager.keyNavigator.currentState.pushNamed("Home");
            break;
        }
      }
      AppStateManager.lastPageIndex = value;
    });
  }

  String getAppBarTitle() {
    String title = "";
    setState(() {
      switch (AppStateManager.lastPageIndex) {
        case 0:
          title = "My Bartender";
          break;
        case 1:
          title = "Favorite";

          break;
        case 2:
          title = "Drinks";

          break;
        case 3:
          title = "Settings";

          break;
        default:
          title = "";

          break;
      }
    });
    return title;
  }
}
