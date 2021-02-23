import 'package:flutter/material.dart';

class BeverageConfiguration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.width * 0.9,
        child: Text("Hier Beverage Konfiguration einfügen"),
      ),
    );
  }
}
