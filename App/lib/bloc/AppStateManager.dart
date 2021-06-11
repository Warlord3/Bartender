import 'package:bartender/GlobalWidgets/NotifcationOverlay.dart';
import 'package:bartender/bloc/DataManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ThemeManager.dart';

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
  static bool initConnection = false;
  static List<bool> showMoreInfo;

  static Size screenSize = Size(0, 0);

  static OverlayEntry settingsOverlayEntry;
  static bool settingsOverlayVisible = false;
  static OverlayEntry progressOverlay;
  static bool progressOverlayVisible = false;

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

  static void showProgressOverlay() {
    if (!progressOverlayVisible) {
      progressOverlayVisible = true;
      progressOverlay = OverlayEntry(
        builder: (buildContext) => Positioned(
          bottom: 15,
          left: 15,
          child: Container(
            height: 50,
            width: screenSize.width - 30,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(buildContext).backgroundColor),
            child: Center(
              child: Selector<DataManager, int>(
                builder: (context, data, child) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    value: data / 100,
                  ),
                ),
                selector: (buildContext, dataManager) =>
                    dataManager.drinkProgress,
              ),
            ),
          ),
        ),
      );
      if (progressOverlay == null) return;
      keyNavigator.currentState.overlay.insert(progressOverlay);
    }
  }

  static void removeProgressOverlay() {
    if (progressOverlayVisible) {
      progressOverlay?.remove();
      progressOverlayVisible = false;
    }
  }

  static void removeSettingsOverlay() {
    if (settingsOverlayVisible) {
      settingsOverlayEntry?.remove();
      settingsOverlayVisible = false;
    }
  }

  static void dispose() {
    removeSettingsOverlay();
    removeProgressOverlay();
  }
}
