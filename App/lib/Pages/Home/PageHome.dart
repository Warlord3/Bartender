import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bartender/bloc/ThemeManager.dart';

class HomePage extends StatefulWidget {
  @override
  _HOmePageState createState() => _HOmePageState();
}

class _HOmePageState extends State<HomePage> {
  ThemeChangerProvider themeChangeProvider;

  @override
  Widget build(BuildContext context) {
    // Get current theme
    themeChangeProvider = Provider.of<ThemeChangerProvider>(context);
    return Container(
      child: Center(
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: InkWell(
                child: Text("Recent"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
