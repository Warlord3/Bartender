import 'package:bartender/Pages/Drinks/LocalWidgets/DrinkConfiguration.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:bartender/models/CommunicationData.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ControllerConfiguration extends StatefulWidget {
  @override
  _ControllerConfigurationState createState() =>
      _ControllerConfigurationState();
}

class _ControllerConfigurationState extends State<ControllerConfiguration> {
  PageController controller;
  int currentpage = 0;
  DataManager dataManager;
  @override
  initState() {
    super.initState();
    controller = PageController(
      initialPage: currentpage,
      keepPage: false,
    );
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dataManager = Provider.of<DataManager>(context);
    return Container(
      color: Theme.of(context).backgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        controller: controller,
        itemCount: dataManager.pumpConfiguration.configs.length,
        itemBuilder: (context, index) => PumpConfiguration(
          pumpIndex: index,
          dataManager: dataManager,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PumpConfiguration extends StatefulWidget {
  PumpConfiguration({
    Key key,
    @required this.pumpIndex,
    @required this.dataManager,
  }) : super(key: key);

  final int pumpIndex;
  final DataManager dataManager;
  LanguageManager languageManager;
  @override
  _PumpConfigurationState createState() => _PumpConfigurationState();
}

class _PumpConfigurationState extends State<PumpConfiguration> {
  TextEditingController _mlPerMinutecontroller;
  TextEditingController _testDonate;
  String beverageName;
  @override
  void initState() {
    super.initState();
    _mlPerMinutecontroller = TextEditingController();
    _testDonate = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    widget.languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    beverageName = widget.dataManager
            .getBeverageByID(widget.dataManager.pumpConfiguration
                .configs[widget.pumpIndex].beverageID)
            ?.name ??
        "None";
    _mlPerMinutecontroller.text =
        "${widget.dataManager.pumpConfiguration.configs[widget.pumpIndex].mlPerMinute}";
    _testDonate.text = "100";

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Pump: ${widget.pumpIndex + 1}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Beverage: $beverageName"),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(beverageName == Beverage.none().name
                      ? "Select"
                      : "Change"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.dataManager.pumpConfiguration
                            .configs[widget.pumpIndex].mechanicalDirection ==
                        enMechanicalDirection.backward
                    ? "Direction: Backward"
                    : "Direction: Forward"),
                Switch(
                  value: widget.dataManager.pumpConfiguration
                          .configs[widget.pumpIndex].mechanicalDirection ==
                      enMechanicalDirection.backward,
                  onChanged: (value) {
                    widget.dataManager.setInverted(
                        widget.pumpIndex,
                        value
                            ? enMechanicalDirection.backward
                            : enMechanicalDirection.forward);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 7,
                  child: Text("Milliliter per Minute"),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    child: TextField(
                      autofocus: false,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9]'),
                        ),
                      ],
                      maxLength: 4,
                      controller: _mlPerMinutecontroller,
                      onChanged: (data) {
                        if (data.isNotEmpty) {
                          widget.dataManager.pumpConfiguration.setMlPerMinute(
                              widget.pumpIndex, int.parse(data));
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'ml per Minute',
                        labelText: "ml",
                        labelStyle: TextStyle(height: 0.8),
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        contentPadding: const EdgeInsets.only(
                          left: 8,
                          bottom: 0.0,
                          top: 0.0,
                        ),
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.dataManager
                        .startPump(widget.pumpIndex, enPumpDirection.forward);
                  },
                  child: Text("Forward"),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.dataManager.stopPump(widget.pumpIndex);
                  },
                  child: Text("Stop"),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.dataManager
                        .startPump(widget.pumpIndex, enPumpDirection.backward);
                  },
                  child: Text("Backward"),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 2,
                  child: TextField(
                    controller: _testDonate,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'ml',
                      labelText: "ml",
                      labelStyle: TextStyle(height: 0.8),
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      contentPadding: const EdgeInsets.only(
                        left: 8,
                        bottom: 0.0,
                        top: 0.0,
                      ),
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.dataManager.sendMilliliter(
                          widget.pumpIndex, int.parse(_testDonate.text));
                    },
                    child: Text("Donate"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future chooseBeverageDialog(BuildContext context) {
    List<Beverage> _searchResult = [];
    List<Beverage> beverages =
        Provider.of<DataManager>(context, listen: false).beverages;
    Color textColor = Theme.of(context).textTheme.bodyText1.color;
    return showDialog(
      context: context,
      builder: (dynamic) {
        return StatefulBuilder(builder: (context, setState) {
          onSearchTextChanged(String text) async {
            _searchResult.clear();
            if (text.isEmpty) {
              setState(() {});
              return;
            }

            beverages.forEach((beverage) {
              if (beverage.name.toLowerCase().contains(text.toLowerCase()))
                _searchResult.add(beverage);
            });
            setState(() {
              if (_searchResult.length == 0) {
                textColor = Colors.red;
              } else {
                textColor = Theme.of(context).textTheme.bodyText1.color;
              }
            });
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            insetPadding: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        onChanged: onSearchTextChanged,
                        style: TextStyle(color: textColor),
                      ),
                      Expanded(
                        child: _searchResult.length != 0
                            ? BeverageList(
                                beverages: _searchResult,
                              )
                            : BeverageList(
                                beverages: beverages,
                              ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
