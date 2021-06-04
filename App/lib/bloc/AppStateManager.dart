import 'package:bartender/GlobalWidgets/NotifcationOverlay.dart';
import 'package:flutter/cupertino.dart';

class AppStateManager {
  static GlobalKey<NavigatorState> keyNavigator = GlobalKey<NavigatorState>();
  static GlobalKey<AnimatedListState> favoriteListKey =
      GlobalKey<AnimatedListState>(debugLabel: "favoriteDrinkKey");
  static GlobalKey<AnimatedListState> drinkListKey =
      GlobalKey<AnimatedListState>(debugLabel: "normalDrinkKey");
  static double scrollPositionFavoritePage = 0.0;
  static double scrollPositionDrinksPage = 0.0;

  static int lastPageIndex = 0;
  static bool pushedPage = false;
  static bool initIP = false;
  static bool initStorage = false;
  static List<bool> showMoreInfo;

  static OverlayEntry settingsOverlayEntry;

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
