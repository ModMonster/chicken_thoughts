import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsManager {
  static void initialize(ValueNotifier<int> currentPageNotifier) {
    final QuickActions quickActions = const QuickActions();
    quickActions.initialize((shortcutType) {
      if (shortcutType == "daily") {
        currentPageNotifier.value = 0;
      } else if (shortcutType == "history") {
        currentPageNotifier.value = 1;
      } else if (shortcutType == "streak") {
        currentPageNotifier.value = 2;
      } else if (shortcutType == "chickendex") {
        currentPageNotifier.value = 3;
      }
    });
    quickActions.setShortcutItems([
      ShortcutItem(
        type: "daily",
        localizedTitle: "Daily",
        icon: "ic_daily"
      ),
      ShortcutItem(
        type: "history",
        localizedTitle: "History",
        icon: "ic_history"
      ),
      ShortcutItem(
        type: "streak",
        localizedTitle: "Streak",
        icon: "ic_streak"
      ),
      ShortcutItem(
        type: "chickendex",
        localizedTitle: "Chickendex",
        icon: "ic_chickendex"
      )
    ]);
  }
}