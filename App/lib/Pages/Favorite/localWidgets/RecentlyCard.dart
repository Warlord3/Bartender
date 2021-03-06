import 'package:bartender/Pages/Favorite/localWidgets/RotationIcon.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:bartender/GlobalWidgets/DrinkListView.dart';
import 'package:bartender/GlobalWidgets/ExpandWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentlyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var maindata = Provider.of<DataManager>(context, listen: false);
    var pageState = Provider.of<PageStateManager>(context);
    pageState.keyRecently =
        GlobalKey<AnimatedListState>(debugLabel: "Recently");
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: pageState.changeExpanded,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40,
                          ),
                          Icon(
                            Icons.timer,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Recently Mixed",
                            style: TextStyle(fontSize: 25),
                          ),
                          Spacer(),
                          ReflectIcon(
                            toolTipNormal: "Show recently mixed Dirnks",
                            toolTipTurned: "Close recently mixed Dirnks",
                            pressed: pageState.recentlyExpanded,
                            onPressed: pageState.changeExpanded,
                          )
                        ],
                      ),
                    ),
                  ),
                  ExpandWidget(
                    child: DrinkListview(
                      drinks: maindata.recentlyCreatedDrinks,
                      drinkType: DrinkType.RecentlyDrinks,
                      refKey: pageState.keyRecently,
                    ),
                    expand: pageState.recentlyExpanded,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
