import 'package:bartender/Pages/Drinks/LocalWidgets/DrinkConfiguration.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
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
      viewportFraction: 0.5,
    );
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dataManager = Provider.of<DataManager>(context, listen: false);
    return Align(
      alignment: Alignment.center,
      child: Container(
        color: Theme.of(context).backgroundColor,
        height: 300,
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: controller,
          itemCount: dataManager.pumpConfiguration.configs.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => controller.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn),
            child: PumpConfiguration(
              pumpIndex: index,
              dataManager: dataManager,
            ),
          ),
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
  TextEditingController controller;
  String beverageName;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    widget.languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    beverageName = widget.dataManager
            .getBeverageByID(widget.dataManager.pumpConfiguration
                .configs[widget.pumpIndex].beverageID)
            ?.name ??
        "Select Beverage";
    controller.text =
        "${widget.dataManager.pumpConfiguration.configs[widget.pumpIndex].mlPerMinute}";
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
            margin: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Pump: ${widget.pumpIndex}",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Divider(
                  color: Colors.blueAccent,
                ),
                Text("Choose Beverage"),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  child: Text(beverageName),
                  onPressed: () async {
                    Beverage result = await chooseBeverageDialog(context);
                    if (result != null) {
                      setState(() {
                        widget.dataManager.pumpConfiguration
                            .setBeverageID(widget.pumpIndex, result.id);
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Divider(
                  color: Colors.blueAccent,
                ),
                Text("Ml per Minute"),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: 200,
                  child: TextField(
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                    textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]'),
                      ),
                    ],
                    maxLength: 4,
                    controller: controller,
                    onChanged: (data) {
                      widget.dataManager.pumpConfiguration
                          .setMlPerMinute(widget.pumpIndex, int.parse(data));
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Ml per Minute',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(25.7),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(25.7),
                        ),
                        counterText: ""),
                  ),
                )
              ],
            )),
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
