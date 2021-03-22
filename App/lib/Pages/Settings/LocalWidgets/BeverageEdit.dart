import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BeverageEditDialog extends StatefulWidget {
  Beverage beverage;
  BeverageEditDialog(this.beverage);

  @override
  _BeverageEditDialogState createState() => _BeverageEditDialogState();
}

class _BeverageEditDialogState extends State<BeverageEditDialog> {
  //controller for Textfield
  TextEditingController _nameController;
  TextEditingController _additionController;
  TextEditingController _percentController;
  TextEditingController _kcalController;
  Beverage newBeverage;
  @override
  initState() {
    newBeverage = widget.beverage.copy();
    super.initState();
    //init textfield with current values
    _nameController = TextEditingController(text: newBeverage.name);
    _additionController = TextEditingController(text: newBeverage.addition);
    _percentController = TextEditingController(text: "${newBeverage.percent}");
    _kcalController = TextEditingController(text: "${newBeverage.kcal}");
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    LanguageManager languageManager = Provider.of(context, listen: false);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onEditingComplete: () =>
                      node.nextFocus(), // Move focus to next
                  textInputAction: TextInputAction.next, //InputAction arrow

                  decoration: decoration(hintText: "Name"),
                  controller: _nameController,
                  onChanged: (value) {
                    newBeverage.name = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onEditingComplete: () =>
                      node.nextFocus(), // Move focus to next
                  textInputAction: TextInputAction.next, //InputAction arrow

                  decoration: decoration(hintText: "Addition"),
                  controller: _additionController,
                  onChanged: (value) {
                    newBeverage.addition = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]+\.[0-9]+'),
                    ),
                  ],
                  onEditingComplete: () =>
                      node.nextFocus(), // Move focus to next
                  textInputAction: TextInputAction.next, //InputAction arrow

                  decoration: decoration(hintText: "Percent"),
                  controller: _percentController,
                  onChanged: (value) {
                    newBeverage.addition = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]+\.[0-9]+'),
                    ),
                  ],
                  onEditingComplete: () => node.unfocus(), // Finish
                  decoration: decoration(hintText: "Kcal"),
                  controller: _kcalController,
                  onChanged: (value) {
                    newBeverage.addition = value;
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Provider.of<DataManager>(context, listen: false)
                        .saveBeverage(newBeverage);
                    Navigator.of(context).pop();
                  },
                  child: Text(languageManager.getData("save")))
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration decoration({String hintText = ""}) {
    return InputDecoration(
      fillColor: Theme.of(context).backgroundColor,
      filled: true,
      focusColor: Colors.green,
      hintText: hintText,
    );
  }
}
