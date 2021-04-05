import 'package:bartender/GlobalWidgets/NotifcationOverlay.dart';
import 'package:flutter/cupertino.dart';

class PageStateManager with ChangeNotifier {
  static GlobalKey<NavigatorState> keyNavigator = GlobalKey<NavigatorState>();
  final GlobalKey<AnimatedListState> favoriteDrink =
      GlobalKey<AnimatedListState>(debugLabel: "favoriteDrinkKey");
  final GlobalKey<AnimatedListState> drinkListist =
      GlobalKey<AnimatedListState>(debugLabel: "normalDrinkKey");
  double scrollPositionFavoritePage = 0.0;
  double scrollPositionDrinksPage = 0.0;

  int lastPageIndex = 0;
  bool pushedPage = false;
  List<bool> showMoreInfo;
  bool recentlyExpanded = false;

  void changeExpanded() {
    recentlyExpanded = !recentlyExpanded;
    notifyListeners();
  }

  static void showOverlayEntry(String text, [NavigatorState navigator]) {
    OverlayEntry entry = OverlayEntry(builder: (BuildContext context) {
      return FunkyNotification(text);
    });
    if (navigator != null) {
      navigator.overlay.insert(entry);
    } else {
      keyNavigator.currentState.overlay.insert(entry);
    }
    Future.delayed(Duration(seconds: 3), () {
      entry.remove();
    });
  }
}
