import 'dart:async';

import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:bartender/bloc/AppStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DrinkConfiguration extends StatefulWidget {
  Drink newDrink;
  DataManager mainData;
  DrinkConfiguration({this.newDrink}) {
    if (this.newDrink == null) {
      this.newDrink = Drink.newDrink();
    }
  }
  @override
  _DrinkConfigurationState createState() => _DrinkConfigurationState();
}

class _DrinkConfigurationState extends State<DrinkConfiguration> {
  List<TextEditingController> _controllers;
  TextEditingController _nameController;
  LanguageManager languageManager;

  String _DrinkNameErrorText = null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.newDrink.name);
    initControllers();
    // KeyboardVisibilityNotification().addNewListener(
    // onChange: (bool visible) {
    // if (!visible) update();
    // },
    // );
  }

  @override
  void dispose() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.mainData = Provider.of<DataManager>(context);
    languageManager = Provider.of<LanguageManager>(context);

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                update();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: TextStyle(fontSize: 30),
                      decoration: InputDecoration(
                        errorText: _DrinkNameErrorText,
                        fillColor: Colors.transparent,
                        labelText: languageManager.getData("drinkname"),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Text(
                            languageManager.getData("ingredients"),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Column(
                            children: widget.newDrink.ingredients
                                .asMap()
                                .map(
                                  (index, element) => MapEntry(
                                    index,
                                    IngredientsEditor(
                                      ingredient: element,
                                      index: index,
                                      controller: _controllers[index],
                                      refresh: update,
                                      delete: deleteIngredient,
                                    ),
                                  ),
                                )
                                .values
                                .toList(),
                          ),
                          Container(
                            color: Colors.transparent,
                            child: Tooltip(
                              message: languageManager
                                  .getData("add_ingredient_to_drink"),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    widget.newDrink.ingredients
                                        .add(Ingredient.empty());
                                    _controllers
                                        .add(TextEditingController(text: "0"));
                                  });
                                },
                                child: Text(
                                    languageManager.getData("add_ingredient")),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      color: Colors.transparent,
                      width: double.infinity,
                      child: Column(
                        children: [
                          DrinkInfoText(
                            infoText: languageManager.getData("ingredients"),
                            value: widget.newDrink.ingredients.length
                                .toStringAsFixed(0),
                          ),
                          DrinkInfoText(
                            infoText: "ml",
                            value: widget.newDrink.amount.toStringAsFixed(0),
                          ),
                          DrinkInfoText(
                            infoText: "%",
                            value: widget.newDrink.percent.toStringAsFixed(1),
                          ),
                          DrinkInfoText(
                            infoText: "Kcal",
                            value: widget.newDrink.kcal.toStringAsFixed(1),
                          )
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_outlined,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    languageManager.getData("save"),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                update();
                                if (widget.newDrink.valid()) {
                                  widget.mainData.saveDrink(widget.newDrink);
                                  setState(() {
                                    widget.newDrink = Drink.newDrink();
                                    clearPage();
                                  });

                                  Navigator.of(context, rootNavigator: true)
                                      .pop(true);
                                  AppStateManager.showOverlayEntry(
                                      "Saved",
                                      AppStateManager
                                          .keyNavigator.currentState);
                                } else {
                                  AppStateManager.showOverlayEntry(
                                      "The is something Missing",
                                      Navigator.of(context));
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.clear_outlined,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    languageManager.getData("cancel"),
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void clearPage() {
    _nameController.clear();
    initControllers();
  }

  void initControllers() {
    _controllers = List<TextEditingController>.generate(
        widget.newDrink.ingredients.length,
        (index) => TextEditingController(
            text: widget.newDrink.ingredients[index].amount.toString()));
  }

  void update() {
    if (_nameController.text != "") {
      widget.newDrink.name = _nameController.text;
      _DrinkNameErrorText = null;
    } else {
      _DrinkNameErrorText = "Drink name can't be empty";
    }
    for (int i = 0; i < _controllers.length; i++) {
      widget.newDrink.ingredients[i].amount = int.parse(_controllers[i].text);
    }
    setState(() {
      widget.newDrink.updateStats();
    });
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  deleteIngredient(int index) {
    setState(() {
      widget.newDrink.ingredients.removeAt(index);
      _controllers.removeAt(index);
    });
    update();
  }
}

// ignore: must_be_immutable
class IngredientsEditor extends StatefulWidget {
  IngredientsEditor(
      {this.ingredient,
      this.index,
      this.refresh,
      this.delete,
      this.controller});
  Function refresh;
  Function(int) delete;
  Ingredient ingredient;
  final int index;
  TextEditingController controller;

  @override
  _IngredientsEditorState createState() => _IngredientsEditorState();
}

class _IngredientsEditorState extends State<IngredientsEditor> {
  List<Beverage> beverages;
  LanguageManager languageManager;

  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context);
    beverages = Provider.of<DataManager>(context, listen: false).beverages;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              widget.ingredient.beverage.valid()
                  ? IconButton(
                      onPressed: () async {
                        await chooseBeverageDialog(context, beverages);
                      },
                      icon: Icon(Icons.mode_edit_outline),
                      splashRadius: 25,
                    )
                  : Container(),
              Text(
                "${widget.index + 1}.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 10,
              ),
              !widget.ingredient.beverage.valid()
                  ? Flexible(
                      flex: 10,
                      fit: FlexFit.tight,
                      child: ElevatedButton(
                        onPressed: () async {
                          await chooseBeverageDialog(context, beverages);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            widget.ingredient.beverage.name == ""
                                ? languageManager.getData("select_beverage")
                                : languageManager.getData("change_beverage"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : Flexible(
                      flex: 10,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.ingredient.beverage.name),
                      ),
                    ),
              SizedBox(
                width: 20,
              ),
              Flexible(
                flex: 3,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: widget.controller,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "ml",
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(
                      fontSize: 17,
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+'),
                    ),
                  ],
                  onSubmitted: (value) => widget.refresh(),
                  onTap: () => widget.controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: widget.controller.value.text.length),
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                    ),
                    onPressed: () {
                      widget.delete(widget.index);
                    },
                    splashRadius: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Future chooseBeverageDialog(
      BuildContext context, List<Beverage> beverages) async {
    List<Beverage> _searchResult = [];
    var result = await showDialog(
      context: context,
      builder: (dynamic) {
        onSearchTextChanged(String text) async {
          _searchResult.clear();
          if (text.isEmpty) {
            setState(() {});
            return;
          }

          beverages.forEach((beverage) {
            if (beverage.name.contains(text)) _searchResult.add(beverage);
          });

          setState(() {});
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
                      child: Text(languageManager.getData("cancel")),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        widget.ingredient.beverage.update(result);
        widget.refresh();
      });
    }
  }
}

class BeverageList extends StatelessWidget {
  BeverageList({this.beverages});
  final List<Beverage> beverages;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[600],
        height: 5,
      ),
      shrinkWrap: true,
      itemCount: beverages.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop(beverages[index]);
              },
              child: Container(
                alignment: Alignment.centerLeft,
                child:
                    Text(beverages[index].name, style: TextStyle(fontSize: 15)),
                width: double.infinity,
                height: 40,
              ),
            ),
          ],
        );
      },
    );
  }
}

class InputTextfield extends StatefulWidget {
  InputTextfield(
      {this.labelText, this.errorMsg, this.shadow, this.textController});

  final BoxShadow shadow;
  final TextEditingController textController;
  final String errorMsg;
  final String labelText;

  @override
  _InputTextfieldState createState() => _InputTextfieldState();
}

class _InputTextfieldState extends State<InputTextfield> {
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [widget.shadow],
      ),
      child: Focus(
        onFocusChange: (value) {
          showError = false;
          if (!value) {
            if (widget.textController.text.trim().isEmpty) {
              showError = true;
            }
          }
          widget.textController.text = rtrim(ltrim(widget.textController.text));
          setState(() {});
        },
        child: TextField(
          controller: widget.textController,
          maxLines: 1,
          style: TextStyle(fontSize: 25),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintStyle: TextStyle(fontSize: 25),
            labelText: widget.labelText,
            alignLabelWithHint: true,
            errorText: showError ? widget.errorMsg : null,
            labelStyle: TextStyle(color: Colors.red),
            enabledBorder: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(20),
          ),
        ),
      ),
    );
  }

  String ltrim(String str) {
    return str.replaceFirst(new RegExp(r"^\s+"), "");
  }

  /// trims trailing whitespace
  String rtrim(String str) {
    return str.replaceFirst(new RegExp(r"\s+$"), "");
  }
}

class DrinkInfoText extends StatelessWidget {
  final String value;
  final String infoText;

  DrinkInfoText({this.value, this.infoText});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyText1,
          children: [
            TextSpan(
                text: "$value ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: infoText),
          ],
        ),
      ),
    );
  }
}
