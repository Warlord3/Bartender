import 'package:bartender/bloc/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bartender/bloc/ConnectionManager.dart';
import 'package:bartender/bloc/ThemeManager.dart';

class HomePage extends StatefulWidget {
  @override
  _HOmePageState createState() => _HOmePageState();
}

class _HOmePageState extends State<HomePage> {
  ThemeChangerProvider themeChangeProvider;
  LanguageManager languageManager;

  @override
  Widget build(BuildContext context) {
    themeChangeProvider = Provider.of<ThemeChangerProvider>(context);
    languageManager = Provider.of<LanguageManager>(context);

    return SingleChildScrollView(
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
                      leading: Icon(Icons.history),
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
                      leading: Icon(Icons.leaderboard),
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
                                Selector<ConnectionManager, bool>(
                                  selector: (_, connection) =>
                                      connection.connected,
                                  builder: (context, value, child) {
                                    return Icon(
                                        value ? Icons.wifi : Icons.wifi_off);
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
                                  child: Text("Mixing Drink"),
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
                                  child: Text("None"),
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
    );
  }
}
