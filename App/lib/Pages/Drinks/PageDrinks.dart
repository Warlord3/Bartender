import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/PageStateManager.dart';
import 'package:bartender/models/Drinks.dart';
import 'package:bartender/GlobalWidgets/DrinkListView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrinksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pageState = Provider.of<PageStateManager>(context, listen: false);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          pageState.scrollPositionDrinksPage = notification.metrics.pixels;
        }
        return true;
      },
      child: Consumer<DataManager>(
        builder: (context, mainData, child) => SafeArea(
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: SingleChildScrollView(
              controller: ScrollController(
                  initialScrollOffset: pageState.scrollPositionFavoritePage),
              child: DrinkListview(
                drinks: mainData.allDrinks,
                drinkType: DrinkType.AllDrinks,
              ),
            ),
          ),
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
