import 'package:bartender/GlobalWidgets/MixDrinkWidget.dart';
import 'package:bartender/Pages/Drinks/LocalWidgets/DrinkConfiguration.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class DrinkListview extends StatelessWidget {
  final List<Drink> drinks;
  final DrinkType drinkType;
  DrinkListview({this.drinks, this.drinkType});

  @override
  Widget build(BuildContext context) {
    DataManager dataManager = Provider.of<DataManager>(context, listen: false);
    GlobalKey<AnimatedListState> key = GlobalKey<AnimatedListState>();
    return Container(
      child: AnimatedList(
        key: key,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index, animation) {
          return Dismissible(
            background: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Container(
                color: Colors.red,
                child: Icon(Icons.delete_outline),
              ),
            ),
            dragStartBehavior: DragStartBehavior.down,
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              dataManager.removeDrink(drinks[index]);
              key.currentState.removeItem(index, (context, animation) => null);
            },
            key: Key(drinks[index].name),
            child: ListTile(
              dataManager: dataManager,
              drink: drinks[index],
              index: index,
              drinkType: drinkType,
              animation: animation,
            ),
          );
        },
        initialItemCount: drinks.length,
      ),
    );
  }
}

// ignore: must_be_immutable
class ListTile extends StatefulWidget {
  Drink drink;
  int index;
  DrinkType drinkType;
  Animation<double> animation;
  DataManager dataManager;

  ListTile(
      {this.dataManager,
      this.drink,
      this.index,
      this.drinkType,
      this.animation});
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
          horizontal: 0,
          vertical: 3,
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
                    MixDringWidget(drink: widget.drink),
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
                        child: Transform.scale(
                          scale: 0.8,
                          child: IconButton(
                            icon: Icon(
                              widget.drink.favorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              if (widget.drinkType ==
                                  DrinkType.FavoriteDrinks) {
                                AnimatedList.of(context).removeItem(
                                    widget.index,
                                    (_, animation) => ListTile(
                                          drink: widget.drink,
                                          index: widget.index,
                                          animation: animation,
                                        ),
                                    duration:
                                        const Duration(milliseconds: 400));
                              }

                              widget.dataManager
                                  .changeFavorite(widget.drink, false);

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
