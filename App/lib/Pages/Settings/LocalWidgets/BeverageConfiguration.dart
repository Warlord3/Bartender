import 'dart:ui';

import 'package:bartender/Pages/Settings/LocalWidgets/BeverageEdit.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeverageConfiguration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DataManager dataManager = Provider.of<DataManager>(context);
    return Center(
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: Column(
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: dataManager.beverages.length,
                      itemBuilder: (context, index) =>
                          BeverageItem(dataManager.beverages[index]),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[500],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      showGeneralDialog(
                        barrierDismissible: true,
                        barrierLabel: '',
                        barrierColor: Colors.black38,
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (ctx, anim1, anim2) =>
                            BeverageEditDialog(Beverage.empty()),
                        transitionBuilder: (ctx, anim1, anim2, child) =>
                            BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: anim1.value * 3,
                            sigmaY: anim1.value * 3,
                          ),
                          child: FadeTransition(
                            child: child,
                            opacity: anim1,
                          ),
                        ),
                        context: context,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.add,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BeverageItem extends StatelessWidget {
  BeverageItem(this.beverage);
  final Beverage beverage;
  @override
  Widget build(BuildContext context) {
    DataManager dataManager = Provider.of<DataManager>(context, listen: false);

    return Dismissible(
      direction: DismissDirection.endToStart,
      key: Key(beverage.name),
      onDismissed: (direction) {
        dataManager.beverages.remove(beverage);
      },
      confirmDismiss: (direction) async {
        if (dataManager.beverageInUse(beverage)) {
          await showGeneralDialog(
            barrierDismissible: true,
            barrierLabel: '',
            barrierColor: Colors.black38,
            transitionDuration: Duration(milliseconds: 200),
            pageBuilder: (ctx, anim1, anim2) => Center(
              child: Material(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Text(
                          "Beverage is in use. Do you really want to delete it?"),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              return Future.value(true);
                            },
                            child: Text("delte"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();

                              return Future.value(false);
                            },
                            child: Text("cancel"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            transitionBuilder: (ctx, anim1, anim2, child) => FadeTransition(
              child: child,
              opacity: anim1,
            ),
            context: context,
          );
        }
        return Future.value(true);
      },
      background: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          color: Colors.red,
          child: Icon(Icons.delete_outline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[500],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          child: InkWell(
            onTap: () {
              showGeneralDialog(
                barrierDismissible: true,
                barrierLabel: '',
                barrierColor: Colors.black38,
                transitionDuration: Duration(milliseconds: 200),
                pageBuilder: (ctx, anim1, anim2) =>
                    BeverageEditDialog(beverage),
                transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: anim1.value * 3,
                    sigmaY: anim1.value * 3,
                  ),
                  child: FadeTransition(
                    child: child,
                    opacity: anim1,
                  ),
                ),
                context: context,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            beverage.name,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          Text(
                            beverage.addition,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${beverage.kcal} kcal",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Text(
                        "${beverage.percent} %",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
