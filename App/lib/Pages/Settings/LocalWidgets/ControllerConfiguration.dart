import 'package:bartender/Pages/Drinks/LocalWidgets/DrinkConfiguration.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControllerConfiguration extends StatefulWidget {
  @override
  _ControllerConfigurationState createState() =>
      _ControllerConfigurationState();
}

class _ControllerConfigurationState extends State<ControllerConfiguration> {
  int pumpIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        pumpIndex > 0
                            ? IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  setState(() {
                                    pumpIndex -= 1;
                                  });
                                },
                              )
                            : Container(),
                        pumpIndex < 15
                            ? IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () {
                                  setState(() {
                                    pumpIndex += 1;
                                  });
                                },
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  PumpConfiguration(pumpIndex: pumpIndex),
                ],
              ),
            )),
      ),
    );
  }
}

class PumpConfiguration extends StatelessWidget {
  PumpConfiguration({
    Key key,
    @required this.pumpIndex,
  }) : super(key: key);

  final int pumpIndex;

  @override
  Widget build(BuildContext context) {
    LanguageManager languageManager = Provider.of<LanguageManager>(context);
    return Table(
      textBaseline: TextBaseline.alphabetic,
      defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
      columnWidths: {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            TableCell(
              child: Text(languageManager.getData("pumpID")),
            ),
            TableCell(
              child: Text("$pumpIndex"),
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: Text(languageManager.getData("beverage")),
            ),
            TableCell(
              child: InputTextfield(),
            ),
          ],
        )
      ],
    );
  }
}
