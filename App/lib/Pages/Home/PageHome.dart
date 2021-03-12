import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
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

  @override
  Widget build(BuildContext context) {
    themeChangeProvider = Provider.of<ThemeManager>(context);
    languageManager = Provider.of<LanguageManager>(context);

    return Container(
      color: Theme.of(context).backgroundColor,
      child: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: [
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
                          child: Column(
                            children: [
                              Text("Recent Drink 1"),
                              Text("Recent Drink 2"),
                              Text("Recent Drink 2"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                                    child: Text(
                                      languageManager.getData("mixing_drink"),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
