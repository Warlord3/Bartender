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
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                    ),
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Favorite Drinks",
                      style: TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
            ),
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
