import 'package:bartender/GlobalWidgets/MixDrinkWidget.dart';
import 'package:bartender/Pages/Drinks/LocalWidgets/DrinkConfiguration.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class DrinkListview extends StatelessWidget {
  final List<Drink> drinks;
  final DrinkType drinkType;
  final GlobalKey<AnimatedListState> refKey;
  DrinkListview({this.drinks, this.drinkType, this.refKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedList(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        key: refKey,
        itemBuilder: (context, index, animation) {
          return ListTile(
            key: ValueKey(drinks[index].id.toString()),
            drink: drinks[index],
            index: index,
            drinkType: drinkType,
            animation: animation,
          );
        },
        initialItemCount: drinks.length,
      ),
    );
  }
}

// ignore: must_be_immutable
class ListTile extends StatefulWidget {
  Key key;
  Drink drink;
  int index;
  DrinkType drinkType;
  Animation<double> animation;

  ListTile({this.key, this.drink, this.index, this.drinkType, this.animation})
      : super(key: key);
  @override
  _ListTileState createState() => _ListTileState();
}

class _ListTileState extends State<ListTile> {
  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      key: Key(widget.index.toString()),
      sizeFactor: widget.animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        child: Card(
          elevation: 3,
          child: InkWell(
            onTap: () {
              showGeneralDialog(
                barrierDismissible: true,
                barrierLabel: '',
                barrierColor: Colors.black38,
                transitionDuration: Duration(milliseconds: 200),
                pageBuilder: (ctx, anim1, anim2) =>
                    MixDringWidget(drinkName: widget.drink.name),
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
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: EdgeInsets.all(15),
                  child: DrinkConfiguration(
                    newDrink: widget.drink,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 6,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Text(
                            widget.drink.name,
                            style: Theme.of(context).textTheme.overline,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            var mainData =
                                Provider.of<MainData>(context, listen: false);
                            var pageManager = Provider.of<PageStateManager>(
                                context,
                                listen: false);

                            switch (widget.drinkType) {
                              case DrinkType.AllDrinks:
                                AnimatedList.of(context).removeItem(
                                    widget.index,
                                    (_, animation) => ListTile(
                                          drink: widget.drink,
                                          index: widget.index,
                                          animation: animation,
                                        ),
                                    duration:
                                        const Duration(milliseconds: 400));
                                break;
                              case DrinkType.FavoriteDrinks:
                              case DrinkType.RecentlyDrinks:
                                int index = mainData.recentlyCreatedDrinks
                                    .indexWhere(
                                        (drink) => drink.id == widget.drink.id);
                                if (index != -1) {
                                  pageManager.keyRecently.currentState
                                      .removeItem(
                                          index,
                                          (_, animation) => ListTile(
                                                drink: widget.drink,
                                                index: index,
                                                animation: animation,
                                              ),
                                          duration: const Duration(
                                              milliseconds: 400));
                                }
                                index = mainData.favoriteDrinks.indexWhere(
                                    (drink) => drink.id == widget.drink.id);
                                if (index != -1) {
                                  pageManager.keyFavorite.currentState
                                      .removeItem(
                                          index,
                                          (_, animation) => ListTile(
                                                drink: widget.drink,
                                                index: index,
                                                animation: animation,
                                              ),
                                          duration: const Duration(
                                              milliseconds: 400));
                                }

                                break;
                              default:
                            }
                            mainData.removeDrink(widget.drink);
                          },
                          iconSize: 30,
                          tooltip: "Delete this Drink",
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Transform.scale(
                          scale: 0.8,
                          child: IconButton(
                            icon: Icon(
                              Icons.favorite,
                              size: 40,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              var pageManager = Provider.of<PageStateManager>(
                                  context,
                                  listen: false);
                              var mainData =
                                  Provider.of<MainData>(context, listen: false);

                              switch (widget.drinkType) {
                                case DrinkType.AllDrinks:
                                  break;
                                case DrinkType.FavoriteDrinks:
                                  pageManager.keyFavorite.currentState
                                      .removeItem(
                                          widget.index,
                                          (_, animation) => ListTile(
                                                drink: widget.drink,
                                                index: widget.index,
                                                animation: animation,
                                              ),
                                          duration: const Duration(
                                              milliseconds: 400));

                                  break;
                                case DrinkType.RecentlyDrinks:
                                  if (widget.drink.favorite) {
                                    int index = mainData.favoriteDrinks
                                        .indexWhere((drink) =>
                                            drink.id == widget.drink.id);
                                    pageManager.keyFavorite.currentState
                                        .removeItem(
                                            index,
                                            (_, animation) => ListTile(
                                                  drink: widget.drink,
                                                  index: index,
                                                  animation: animation,
                                                ),
                                            duration: const Duration(
                                                milliseconds: 400));
                                  } else {
                                    pageManager.keyFavorite.currentState
                                        .insertItem(0);
                                  }

                                  break;
                                default:
                              }
                              mainData.changeFavorite(widget.drink, false);

                              setState(() {});
                            },
                            iconSize: 20,
                            tooltip: "Favor this Drink",
                            padding: EdgeInsets.all(0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "${widget.drink.amount.toStringAsFixed(1)}ml",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Text(
                          "${widget.drink.percent.toStringAsFixed(1)}%",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Text(
                          "${widget.drink.kcal.toStringAsFixed(1)}kcal",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Row> buildIngredient(Drink drink) {
    List<Row> rows = [];
    rows.add(
      Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Text(
                "Beverage",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Text(
                "ml",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Text(
                "%",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Text(
                "kcal",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ]),
    );

    rows.addAll(drink.ingredients.map(
      (ingredient) =>
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Text(
            ingredient.beverage.name,
            style: TextStyle(fontSize: 15, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Text(
            ingredient.amount.toStringAsFixed(1),
            style: TextStyle(fontSize: 15, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Text(
            ingredient.beverage.percent.toStringAsFixed(1),
            style: TextStyle(fontSize: 15, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Text(
            ingredient.beverage.kcal.toStringAsFixed(1),
            style: TextStyle(fontSize: 15, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    ));

    return rows;
  }
}
