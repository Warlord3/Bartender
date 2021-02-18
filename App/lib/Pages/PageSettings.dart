import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/ThemeManager.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeChangerProvider themeChangeProvider;

  @override
  Widget build(BuildContext context) {
    print("rebuild list Settings");
    // Get current theme
    themeChangeProvider = Provider.of<ThemeChangerProvider>(context);
    return Container(
        /*
        Table with settings page content
        */
        child: Table(
      columnWidths: {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(1),
      },
      border: TableBorder.all(), // Todo: Remove border when finished
      children: [
        TableRow(children: [
          TableCell(
            child: Center(child: Text("Dark Theme")),
            verticalAlignment: TableCellVerticalAlignment.middle,
          ),
          TableCell(
            child: Center(
              child: Switch(
                value: themeChangeProvider.isDarkTheme(),
                onChanged: (value) {
                  themeChangeProvider.toggleTheme();
                },
              ),
            ),
          )
        ])
      ],
    ));
  }
}
