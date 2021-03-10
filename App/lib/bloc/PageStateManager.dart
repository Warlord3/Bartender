import 'package:flutter/cupertino.dart';

class PageStateManager with ChangeNotifier {
  GlobalKey<AnimatedListState> keyFavorite;
  GlobalKey<AnimatedListState> keyRecently;
  static GlobalKey<NavigatorState> keyNavigator = GlobalKey<NavigatorState>();

  double scrollPositionFavoritePage = 0.0;
  double scrollPositionDrinksPage = 0.0;

  int lastPageIndex = 0;

  List<bool> showMoreInfo;
  bool recentlyExpanded = false;

  void changeExpanded() {
    recentlyExpanded = !recentlyExpanded;
    notifyListeners();
  }
}
