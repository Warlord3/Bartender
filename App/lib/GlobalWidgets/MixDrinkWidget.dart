import 'dart:ui';

import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MixDringWidget extends StatelessWidget {
  final Drink drink;
  MixDringWidget({this.drink});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        bottom: 100,
        child: Container(
          width: 400,
          height: 200,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        "Mix",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        drink.name,
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    disabledElevation: 1,
                    shape: CircleBorder(),
                    elevation: 0,
                    padding: EdgeInsets.all(10.0),
                    onPressed: () {
                      Provider.of<DataManager>(context, listen: false)
                          .sendDrink(drink);
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    fillColor: Colors.green.withOpacity(0.3),
                    child: SizedBox(
                      child: Icon(
                        Icons.done,
                        color: Colors.green[400],
                        size: 40,
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    disabledElevation: 1,
                    shape: CircleBorder(),
                    elevation: 0,
                    padding: EdgeInsets.all(10.0),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    fillColor: Colors.red.withOpacity(0.3),
                    child: Icon(
                      Icons.clear,
                      color: Colors.red[600],
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
