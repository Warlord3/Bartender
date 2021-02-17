import 'package:bartender/Pages/DrinkEdit/PageDrinkEdit.dart';
import 'package:bartender/Pages/Favorite/PageFavorite.dart';
import 'package:bartender/Pages/Ingredients/PageIngredients.dart';
import 'package:bartender/Pages/PageSettings.dart';
import 'package:flutter/material.dart';
import 'package:bartender/Pages/PageDrinks.dart';

import 'BeverageEdit/PageBeverageEdit.dart';

class PageRouter extends StatefulWidget {
  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Drinks"),
      ),
      body: SafeArea(
        child: Navigator(
          key: _navigatorKey,
          initialRoute: "/",
          onGenerateRoute: (RouteSettings settings) {
            Widget page;
            switch (settings.name) {
              case "/":
                page = FavoritePage();
                break;
              case "/Drinks":
                page = DrinksPage();
                break;
              case "/Ingredients":
                page = IngredientsPage();
                break;
              case "/Settings":
                page = SettingsPage();
                break;
            }
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
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
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text("Favorite"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_drink,
              color: Colors.greenAccent[400],
            ),
            title: Text("Drinks"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.terrain,
              color: Colors.blue,
            ),
            title: Text("Ingredients"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: Colors.grey[800],
            ),
            title: Text("Settings"),
          )
        ],
        onTap: _pageSelect,
        currentIndex: _selectedPage,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(fontSize: 15),
      ),
      floatingActionButton: showFloatingButton(),
    );
  }

  void _pageSelect(int value) {
    setState(() {
      if (_selectedPage != value) {
        switch (value) {
          case 0:
            _navigatorKey.currentState.pushNamed("/");

            break;
          case 1:
            _navigatorKey.currentState.pushNamed("/Drinks");

            break;
          case 2:
            _navigatorKey.currentState.pushNamed("/Ingredients");
            break;
          case 3:
            _navigatorKey.currentState.pushNamed("/Settings");
            break;
        }
      }
      _selectedPage = value;
    });
  }

  Widget showFloatingButton() {
    Widget page;
    switch (_selectedPage) {
      case 0:
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
      heroTag: "FloatingButton$_selectedPage",
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
