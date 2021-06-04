import 'dart:ui';

import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/AppStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:bartender/GlobalWidgets/DrinkListView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LocalWidgets/DrinkConfiguration.dart';

class DrinksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DataManager dataManager = Provider.of<DataManager>(context, listen: false);
    AppStateManager.drinkListKey =
        GlobalKey<AnimatedListState>(debugLabel: "favoriteDrinkKey");
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          AppStateManager.scrollPositionDrinksPage =
              notification.metrics.pixels;
        }
        return true;
      },
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: Stack(
          children: [
            DrinkListview(
                drinks: dataManager.allDrinks,
                drinkType: DrinkType.AllDrinks,
                animatedListKey: AppStateManager.drinkListKey),
            Positioned(
              bottom: 15,
              right: 15,
              child: FloatingActionButton(
                onPressed: () async {
                  var result = await showGeneralDialog(
                    barrierDismissible: true,
                    barrierLabel: '',
                    transitionDuration: Duration(milliseconds: 300),
                    pageBuilder: (ctx, anim1, anim2) => Center(
                      child: Container(
                        child: ConstrainedBox(
                          child: DrinkConfiguration(),
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
                  if (result) {
                    AppStateManager.drinkListKey.currentState
                        .insertItem(dataManager.allDrinks.length - 1);
                  }
                },
                child: Icon(Icons.add),
                hoverElevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  ExpandedSection({this.expand = false, this.child});

  @override
  _ExpandedSectionState createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  AnimationController expandController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    Animation curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeIn,
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axisAlignment: 1.0, sizeFactor: animation, child: widget.child);
  }
}
