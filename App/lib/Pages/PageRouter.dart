import 'package:bartender/Pages/Drinks/PageDrinks.dart';
import 'package:bartender/Pages/Drinks/SubPage/DrinkEdit/PageDrinkEdit.dart';
import 'package:bartender/Pages/Favorite/PageFavorite.dart';
import 'package:bartender/Pages/Beverage/PageBeverage.dart';
import 'package:bartender/Pages/Beverage/SubPage/BeverageEdit/PageBeverageEdit.dart';
import 'package:bartender/Pages/Settings/PageSettings.dart';
import 'package:bartender/Pages/Home/PageHome.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bartender/bloc/LanguageManager.dart';

import 'Start/PageStart.dart';

final _navigatorKey = GlobalKey<NavigatorState>();
int _selectedPage = 0;

class PageRouter extends StatefulWidget {
  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {
  LanguageManager languageManager;
  PageStateManager pageState;

  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context);
    pageState = Provider.of<PageStateManager>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Navigator(
          key: _navigatorKey,
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.orange,
            ),
            label: languageManager.getData("home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            label: languageManager.getData("favorite"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_drink,
              color: Colors.greenAccent[400],
            ),
            label: languageManager.getData("drinks"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.liquor,
              color: Colors.blue,
            ),
            label: languageManager.getData("beverages"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: Colors.grey[800],
            ),
            label: languageManager.getData("settings"),
          )
        ],
        onTap: _pageSelect,
        currentIndex: pageState.lastPageIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.transparent,
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(fontSize: 15),
      ),
      floatingActionButton: showFloatingButton(),
    );
  }

  void _pageSelect(int value) {
    setState(() {
      if (pageState.lastPageIndex != value) {
        switch (value) {
          case 0:
            _navigatorKey.currentState.pushNamed("/Home");
            break;
          case 1:
            _navigatorKey.currentState.pushNamed("/Favorite");
            break;
          case 2:
            _navigatorKey.currentState.pushNamed("/Drinks");
            break;
          case 3:
            _navigatorKey.currentState.pushNamed("/Beverages");
            break;
          case 4:
            _navigatorKey.currentState.pushNamed("/Settings");
            break;
          default:
            _navigatorKey.currentState.pushNamed("/Home");
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
    Widget page;
    switch (pageState.lastPageIndex) {
      case 1:
        page = DrinkEditPage();
        break;
      case 2:
        page = BeverageEditPage();
        break;
      default:
        return null;
    }
    return FloatingActionButton(
      elevation: 10,
      backgroundColor: Colors.red,
      shape: CircleBorder(),
      heroTag: "FloatingButton$pageState.lastPageIndex",
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: EdgeInsets.all(15),
            child: page,
          ),
        );
      },
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
