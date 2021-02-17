import 'package:bartender/bloc/PageStateManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'localWidgets/FavoriteCard.dart';
import 'localWidgets/RecentlyCard.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pageState = Provider.of<PageStateManager>(context, listen: false);
    return Container(
      color: Theme.of(context).backgroundColor,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            pageState.scrollPositionFavoritePage = notification.metrics.pixels;
          }
        },
        child: SingleChildScrollView(
          controller: ScrollController(initialScrollOffset: pageState.scrollPositionFavoritePage),
          child: Column(
            children: [
              RecentlyCard(),
              SizedBox(
                height: 10,
              ),
              FavoriteCard(),
            ],
          ),
        ),
      ),
    );
  }
}
