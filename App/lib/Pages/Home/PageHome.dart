import 'package:bartender/bloc/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    return Container(
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                languageManager.getData("connected"),
                              ),
                              Icon(Icons.done),
                              // ToDo add check for connected or not
                              //Icon(Icons.Icons.clear)
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
    );
  }
}
