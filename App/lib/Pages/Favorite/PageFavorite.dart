import 'package:bartender/GlobalWidgets/DrinkListView.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pageState = Provider.of<PageStateManager>(context, listen: false);
    var maindata = Provider.of<DataManager>(context, listen: false);

    return Container(
      color: Theme.of(context).backgroundColor,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            pageState.scrollPositionFavoritePage = notification.metrics.pixels;
          }
          return true;
        },
        child: SingleChildScrollView(
          controller: ScrollController(
              initialScrollOffset: pageState.scrollPositionFavoritePage),
          child: DrinkListview(
            drinks: maindata.favoriteDrinks,
            drinkType: DrinkType.FavoriteDrinks,
          ),
        ),
      ),
    );
  }
}
