import 'package:flutter/material.dart';

class ControllerConfiguration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.width * 0.9,
        child: Text("Hier Controller Konfiguration einfügen"),
      ),
    );
  }
}
