import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:bartender/GlobalWidgets/DrinkListView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var maindata = Provider.of<DataManager>(context, listen: false);
    var pageState = Provider.of<PageStateManager>(context);
    pageState.keyFavorite =
        GlobalKey<AnimatedListState>(debugLabel: "Favorite");

    return DrinkListview(
      drinks: maindata.favoriteDrinks,
      drinkType: DrinkType.FavoriteDrinks,
      refKey: pageState.keyFavorite,
    );
  }
}
