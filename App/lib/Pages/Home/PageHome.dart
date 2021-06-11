import 'package:bartender/Pages/Drinks/LocalWidgets/DrinkHelper.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bartender/bloc/ThemeManager.dart';

class HomePage extends StatefulWidget {
  @override
  _HOmePageState createState() => _HOmePageState();
}

class _HOmePageState extends State<HomePage> {
  ThemeManager themeChangeProvider;
  LanguageManager languageManager;
  DataManager dataManager;

  @override
  Widget build(BuildContext context) {
    themeChangeProvider = Provider.of<ThemeManager>(context);
    languageManager = Provider.of<LanguageManager>(context);
    dataManager = Provider.of<DataManager>(context);
    return Container(
      color: Theme.of(context).backgroundColor,
      child: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: [
                /*
                  Controller Info
                */
                Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.leaderboard_outlined,
                        ),
                        title: Text(
                          languageManager.getData("bartender_info"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          // ? Maybe consider using a table or grid for better displayment
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Selector<DataManager, bool>(
                                    selector: (_, connection) =>
                                        connection.websocket.connected,
                                    builder: (context, value, child) {
                                      return Icon(value
                                          ? Icons.wifi_outlined
                                          : Icons.wifi_off_outlined);
                                    },
                                  ),
                                  // ToDo add check for connected or not
                                  // ? Maybe use text instead of icons for better displayment in grid / table
                                  //Icon(Icons.Icons.clear)
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    languageManager.getData("status") + ":",
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Selector<DataManager, int>(
                                      builder: (context, data, child) {
                                        return Text(
                                            '${languageManager.getData("mixing_drink")} : $data%');
                                      },
                                      selector: (buildContext, countPro) =>
                                          countPro.drinkProgress,
                                    ),
                                  ),
                                  // ToDo add bartender status
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    languageManager.getData("problems") + ":",
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child:
                                        Text(languageManager.getData("none")),
                                  ),
                                  // ToDo add bartender error
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /*
                  Recent Drinks
                */
                Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.history_outlined,
                        ),
                        title: Text(
                          languageManager.getData("recent_drinks"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: dataManager.recentlyCreatedDrinks.length > 0
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: dataManager
                                        .recentlyCreatedDrinks.length,
                                    itemBuilder: (buildcontext, index) {
                                      return RecentlyDrinkItem(
                                          dataManager
                                              .recentlyCreatedDrinks[index],
                                          index);
                                    })
                                : Text("None Recently Drinks")),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecentlyDrinkItem extends StatelessWidget {
  final Drink recentlyCreatedDrink;
  final int index;
  RecentlyDrinkItem(this.recentlyCreatedDrink, this.index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Colors.grey,
              )),
          child: Center(
              child: Column(
            children: [
              Text(
                recentlyCreatedDrink.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(recentlyCreatedDrink.amount.toStringAsFixed(2)),
                    Text(recentlyCreatedDrink.kcal.toStringAsFixed(2)),
                    Text(recentlyCreatedDrink.percent.toStringAsFixed(2)),
                  ],
                ),
              )
            ],
          )),
        ),
        onTap: () async {
          await drinkSelectDialog(context, recentlyCreatedDrink);
          print("drink from Recentlist");
        },
      ),
    );
  }
}
