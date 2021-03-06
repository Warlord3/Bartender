import 'package:bartender/bloc/DataManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LocalWidgets/PageBeverageEdit.dart';

class BeveragePage extends StatefulWidget {
  @override
  _BeveragePageState createState() => _BeveragePageState();
}

class _BeveragePageState extends State<BeveragePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataManager>(
      builder: (context, mainData, child) => SafeArea(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: SingleChildScrollView(
              child: AnimatedList(
            itemBuilder: (context, index, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: Card(
                    elevation: 3,
                    child: InkWell(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            insetPadding: EdgeInsets.all(15),
                            child: BeverageEditPage(
                              beverage: mainData.beverages[index],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Expanded(
                                    child: Text(
                                      mainData.beverages[index].name,
                                      style:
                                          Theme.of(context).textTheme.overline,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {},
                                    iconSize: 30,
                                    tooltip: "Delete this Beverage",
                                    padding: EdgeInsets.all(0),
                                  ),
                                ],
                              ),
                              Text(
                                mainData.beverages[index].name,
                                style: Theme.of(context).textTheme.subtitle1,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(
                                      mainData.beverages[index].kcal
                                              .toStringAsFixed(1) +
                                          " Kcal",
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(
                                      mainData.beverages[index].percent
                                              .toStringAsFixed(1) +
                                          " %",
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            initialItemCount: mainData.beverages.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
          )),
        ),
      ),
    );
  }
}
