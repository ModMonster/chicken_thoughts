import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsManager {
  static void initialize(ValueNotifier<int> currentPageNotifier) {
    final QuickActions quickActions = const QuickActions();
    quickActions.initialize((shortcutType) {
      if (shortcutType == "history") {
        currentPageNotifier.value = 1;
      } else if (shortcutType == "streak") {
        currentPageNotifier.value = 2;
      } else if (shortcutType == "chickendex") {
        currentPageNotifier.value = 3;
      }
    });
    quickActions.setShortcutItems([
      ShortcutItem(
        type: "history",
        localizedTitle: "History"
      ),
      ShortcutItem(
        type: "streak",
        localizedTitle: "Streak"
      ),
      ShortcutItem(
        type: "chickendex",
        localizedTitle: "Chickendex"
      )
    ]);
  }
}