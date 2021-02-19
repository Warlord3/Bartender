import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:bartender/GlobalWidgets/DrinkListView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var maindata = Provider.of<MainData>(context, listen: false);
    var pageState = Provider.of<PageStateManager>(context);
    pageState.keyFavorite =
        GlobalKey<AnimatedListState>(debugLabel: "Favorite");

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            DrinkListview(
              drinks: maindata.favoriteDrinks,
              drinkType: DrinkType.FavoriteDrinks,
              refKey: pageState.keyFavorite,
            ),
          ],
        ),
      ),
    );
  }
}
