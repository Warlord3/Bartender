import 'dart:ui';

import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MixDringWidget extends StatefulWidget {
  final Drink drink;
  MixDringWidget({this.drink});
  final int divisionCount = 10;
  @override
  _MixDringWidgetState createState() => _MixDringWidgetState();
}

class _MixDringWidgetState extends State<MixDringWidget> {
  double value;
  double minValue;

  @override
  void initState() {
    super.initState();
    value = widget.drink.amount.toDouble();
    minValue = widget.drink.amount / widget.drink.lowestAmountIngredient();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        bottom: 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 400,
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
                          widget.drink.name,
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //TODO: Set textTheme
                Text(
                  "${value.truncate()} ml",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackShape: RoundedRectSliderTrackShape(),
                    trackHeight: 4.0,
                    activeTickMarkColor: Colors.blueAccent,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                    tickMarkShape: RoundSliderTickMarkShape(),
                    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                    valueIndicatorTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: Slider(
                    onChanged: (double newValue) {
                      setState(() {
                        this.value = newValue;
                      });
                    },
                    label: "${value.truncate()}",
                    value: value,
                    min: minValue,
                    max: 1000,
                    divisions: (1000 - minValue) ~/ 10,
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
                            .sendDrink(widget.drink,
                                scalling: widget.drink.scalling(this.value));
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
      ),
    ]);
  }
}
