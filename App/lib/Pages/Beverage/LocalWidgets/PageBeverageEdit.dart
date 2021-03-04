import 'package:bartender/Resources/Style.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class BeverageEditPage extends StatefulWidget {
  Beverage beverage;
  BeverageEditPage({this.beverage}) {
    if (beverage == null) {
      beverage = Beverage.empty();
    }
  }
  @override
  _BeverageEditPageState createState() => _BeverageEditPageState();
}

class _BeverageEditPageState extends State<BeverageEditPage> {
  double percent = 0.0;
  TextEditingController _name;
  TextEditingController _addtion;
  TextEditingController _kcal;
  TextEditingController _percent;

  @override
  void initState() {
    _name = TextEditingController(text: widget.beverage.name);
    _addtion = TextEditingController(text: widget.beverage.addition);
    _kcal = TextEditingController(text: widget.beverage.kcal.toString());
    _percent = TextEditingController(text: widget.beverage.percent.toStringAsFixed(1));
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _addtion.dispose();
    _kcal.dispose();
    _percent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [Style.shadow],
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Create/Edit Beverage",
                        style: Theme.of(context).textTheme.overline,
                      ),
                      Style.sizedBox,
                      TextField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: "Beveragename",
                        ),
                        style: TextStyle(fontSize: 22),
                      ),
                      Style.sizedBox,
                      TextField(
                        controller: _addtion,
                        decoration: InputDecoration(
                          labelText: "Addition",
                        ),
                        style: TextStyle(fontSize: 22),
                      ),
                      Style.sizedBox,
                      TextField(
                        controller: _kcal,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Kcal",
                        ),
                        style: TextStyle(fontSize: 22),
                      ),
                      Style.sizedBox,
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            flex: 2,
                            child: TextField(
                                controller: _percent,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "%",
                                ),
                                style: TextStyle(fontSize: 22),
                                onTap: () => _percent.selection = TextSelection(baseOffset: 0, extentOffset: _percent.value.text.length),
                                onSubmitted: (value) {
                                  setState(() {
                                    percent = double.parse(_percent.text);
                                  });
                                }),
                          ),
                          Flexible(
                            flex: 7,
                            child: Slider(
                              onChanged: (value) => setState(() {
                                percent = value;
                                _percent.text = percent.toStringAsFixed(1);
                                _percent.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _percent.text.length),
                                );
                              }),
                              value: percent,
                              max: 100,
                              min: 0,
                              divisions: 1000,
                              label: percent.toStringAsFixed(1) + "%",
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [Style.shadow],
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          update();
                          if (save()) clearPage();
                        },
                        child: Text("Save and New"),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          update();
                          save();
                          Navigator.of(context).pop();
                        },
                        child: Text("Save"),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool save() {
    if (widget.beverage.valid()) {
      Provider.of<MainData>(context, listen: false).saveBeverage(widget.beverage);
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Missing Fields"),
          content: Text("Please fill and select all Fields"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    return false;
  }

  void update() {
    widget.beverage.name = _name.text;
    widget.beverage.addition = _addtion.text;
    widget.beverage.kcal = double.parse(_kcal.text);
    widget.beverage.percent = double.parse(_percent.text);
    setState(() {});
  }

  void clearPage() {
    setState(() {
      _name.clear();
      _addtion.clear();
      _kcal.text = "0.0";
      _percent.text = "0.0";
      percent = 0.0;
    });
  }
}
