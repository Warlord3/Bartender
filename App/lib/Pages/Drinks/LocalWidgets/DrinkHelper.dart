import 'package:bartender/models/Drinks.dart';
import 'package:flutter/material.dart';

import 'DrinkConfiguration.dart';

Future<bool> drinkEditDialog(BuildContext context,[Drink newDrink]){
return showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (ctx, anim1, anim2) => Center(
      child: Container(
        child: ConstrainedBox(
          child: DrinkConfiguration(newDrink: newDrink,),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
        ),
      ),
    ),
    transitionBuilder: (ctx, anim1, anim2, child) =>
        SlideTransition(
      child: child,
      position: anim1.drive(
          Tween(begin: Offset(0.0, 1.0), end: Offset.zero)),
    ),
    context: context,
  );
}