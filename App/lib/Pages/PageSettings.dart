import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    print("rebuild list Settings");
    return Container(
      child: Column(
        children: [
          Text("Benachrichtung"),
          FlatButton(
            onPressed: () {},
            child: Text("Drücken"),
            color: Theme.of(context).buttonColor,
          )
        ],
      ),
    );
  }
}
