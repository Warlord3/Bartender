import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bartender/bloc/ThemeManager.dart';

class ControllerConfigurationPage extends StatefulWidget {
  @override
  _ControllerConfigurationPageState createState() =>
      _ControllerConfigurationPageState();
}

class _ControllerConfigurationPageState
    extends State<ControllerConfigurationPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Controller Configuration Page"),
      ),
    );
  }
}
