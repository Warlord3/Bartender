import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    print("rebuild list Settings");
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Color(0xff424242),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("My Bartender"),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                  child: Icon(Icons.local_drink),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
