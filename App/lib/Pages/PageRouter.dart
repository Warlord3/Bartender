import 'dart:ui';

import 'package:bartender/Pages/Drinks/PageDrinks.dart';
import 'package:bartender/Pages/Favorite/PageFavorite.dart';
import 'package:bartender/Pages/Beverage/PageBeverage.dart';
import 'package:bartender/Pages/Settings/PageSettings.dart';
import 'package:bartender/Pages/Home/PageHome.dart';
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
  PageStateManager pageState;
  ThemeManager themeChangeProvider;

  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context);
    pageState = Provider.of<PageStateManager>(context);
    themeChangeProvider = Provider.of<ThemeManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppBarTitle()),
      ),
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () async {
          print("pop");
          if (PageStateManager.keyNavigator.currentState.canPop() &&
              pageState.pushedPage) {
            pageState.pushedPage = false;
            PageStateManager.keyNavigator.currentState.pop();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: SafeArea(
          child: Navigator(
            key: PageStateManager.keyNavigator,
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
        currentIndex: pageState.lastPageIndex,
        unselectedItemColor: Colors.transparent,
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(fontSize: 15),
      ),
      floatingActionButton: showFloatingButton(),
    );
  }

  void _pageSelect(int value) {
    pageState = Provider.of(context, listen: false);
    setState(() {
      if (pageState.lastPageIndex != value) {
        switch (value) {
          case 0:
            PageStateManager.keyNavigator.currentState.pushNamed("/Home");
            break;
          case 1:
            PageStateManager.keyNavigator.currentState.pushNamed("/Favorite");
            break;
          case 2:
            PageStateManager.keyNavigator.currentState.pushNamed("/Drinks");
            break;
          case 3:
            PageStateManager.keyNavigator.currentState.pushNamed("/Settings");
            break;
          default:
            PageStateManager.keyNavigator.currentState.pushNamed("/Home");
            break;
        }
      }
      pageState.lastPageIndex = value;
    });
  }

  /*
    We only show the Floating action button on the following pages:
      - Drinks
      - Beverages
  */
  Widget showFloatingButton() {
    Widget widget;
    switch (pageState.lastPageIndex) {
      case 2:
        widget = DrinkConfiguration();
        break;
      default:
        return null;
    }
    return FloatingActionButton(
      elevation: 10,
      shape: CircleBorder(),
      heroTag: "FloatingButton$pageState.lastPageIndex",
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
      switch (pageState.lastPageIndex) {
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
