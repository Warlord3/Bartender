import 'dart:ui';
import 'package:bartender/Pages/Drinks/PageDrinks.dart';
import 'package:bartender/Pages/Favorite/PageFavorite.dart';
import 'package:bartender/Pages/Beverage/PageBeverage.dart';
import 'package:bartender/Pages/Settings/PageSettings.dart';
import 'package:bartender/Pages/Home/PageHome.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/bloc/ThemeManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bartender/bloc/LanguageManager.dart';

import 'Drinks/LocalWidgets/DrinkConfiguration.dart';
import 'Start/PageStart.dart';

class PageRouter extends StatefulWidget {
  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {
  LanguageManager languageManager;
  ThemeManager themeChangeProvider;

  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context);
    themeChangeProvider = Provider.of<ThemeManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppBarTitle()),
      ),
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () async {
          print("pop");
          if (AppStateManager.keyNavigator.currentState.canPop() &&
              AppStateManager.pushedPage) {
            AppStateManager.pushedPage = false;
            AppStateManager.keyNavigator.currentState.pop();
            DataManager dataManager =
                Provider.of<DataManager>(context, listen: false);
            dataManager.stopAllPumps();
            dataManager.normalMode();

            return Future.value(false);
          }
          return Future.value(true);
        },
        child: SafeArea(
          child: Navigator(
            key: AppStateManager.keyNavigator,
            initialRoute: "/Home",
            onGenerateRoute: (RouteSettings settings) {
              Widget page = Container();
              switch (settings.name) {
                case "/Home":
                  page = HomePage();
                  break;
                case "/Favorite":
                  page = FavoritePage();
                  break;
                case "/Drinks":
                  page = DrinksPage();
                  break;
                case "/Beverages":
                  page = BeveragePage();
                  break;
                case "/Settings":
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
      floatingActionButton: showFloatingButton(),
    );
  }

  void _pageSelect(int value) {
    setState(() {
      if (AppStateManager.lastPageIndex != value) {
        switch (value) {
          case 0:
            AppStateManager.keyNavigator.currentState.pushNamed("/Home");
            break;
          case 1:
            AppStateManager.keyNavigator.currentState.pushNamed("/Favorite");
            break;
          case 2:
            AppStateManager.keyNavigator.currentState.pushNamed("/Drinks");
            break;
          case 3:
            AppStateManager.keyNavigator.currentState.pushNamed("/Settings");
            break;
          default:
            AppStateManager.keyNavigator.currentState.pushNamed("/Home");
            break;
        }
      }
      AppStateManager.lastPageIndex = value;
    });
  }

  /*
    We only show the Floating action button on the following pages:
      - Drinks
      - Beverages
  */
  Widget showFloatingButton() {
    Widget widget;
    switch (AppStateManager.lastPageIndex) {
      case 2:
        widget = DrinkConfiguration();
        break;
      default:
        return null;
    }
    return FloatingActionButton(
      elevation: 10,
      shape: CircleBorder(),
      heroTag: "FloatingButton$AppStateManager.lastPageIndex",
      onPressed: () {
        showGeneralDialog(
          barrierDismissible: true,
          barrierLabel: '',
          barrierColor: Colors.black38,
          transitionDuration: Duration(milliseconds: 200),
          pageBuilder: (ctx, anim1, anim2) => widget,
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
      child: Icon(
        Icons.add_outlined,
        color: Colors.white,
        size: 30,
      ),
    );
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
