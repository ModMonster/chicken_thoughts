import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class StreakManager {
  static final List<StreakMilestone> milestones = [
    StreakMilestone(7, name: "Egg"),
    StreakMilestone(14, name: "Baby Chicken"),
    StreakMilestone(30, name: "Chicken"),
    StreakMilestone(50, name: "Hackerbirb"), // https://www.instagram.com/p/C0rXEZcOAD0/
    StreakMilestone(75, name: "Sherlock Chicken"),
    StreakMilestone(100, name: "Blue Boy"),
    StreakMilestone(150, name: "Cas & Zeke"),
    StreakMilestone(200, name: "Real-Life Chicken"),
    StreakMilestone(300, name: "Tai Tai"),
    StreakMilestone(365, name: "Petrie"), // https://www.reddit.com/r/Chicken_Thoughts/comments/1e7w7lq/inspired_by_patrick_and_nicolettes_conure_petrie/
    StreakMilestone(400, name: "Prospector Chicken"), // https://www.instagram.com/p/DBouLpgx8FX/
    StreakMilestone(500, name: "Cordelia"), // https://www.instagram.com/chickenthoughtsofficial/p/C-NkctOC5Yo/
    StreakMilestone(600, name: "Sammie"), // https://www.instagram.com/p/C9kXuOAqeKa/
    StreakMilestone(730, name: "Chicken Plushie"),
    StreakMilestone(1000, name: "Real-Life *Actual* Chicken"),
  ];

  static Future<void> handleStreak() async {
    // Streak stuff
    final Box box = Hive.box("settings");
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(Duration(days: 1));
    final DateTime? lastViewed = box.get("streak.last_viewed");

    if (kDebugMode) print("Last viewed: $lastViewed");

    box.put("streak.last_viewed", now);

    if (lastViewed == null) return;
    if (DateUtils.isSameDay(lastViewed, now)) return;
    
    // Wasn't yesterday; reset streak
    if (!DateUtils.isSameDay(lastViewed, yesterday)) {
      if (kDebugMode) print("Resetting streak :(");
      box.put("streak", 0);
      return;
    }
    
    if (kDebugMode) print("Streak go up!");
    int streak = box.get("streak", defaultValue: 0) + 1;
    box.put("streak", streak);
    if (streak > box.get("streak.longest", defaultValue: 0)) box.put("streak.longest", streak);
    box.put("streak.animate", true);
  }

  static StreakMilestone getNextMilestone() {
    int longestStreak = Hive.box("settings").get("streak.longest", defaultValue: 0);
    for (int i = 0; i < milestones.length; i++) {
      if (longestStreak < milestones[i].day) return milestones[i];
    }
    return milestones.first;
  }
  
  static StreakMilestone? getLatestMilestone() {
    return getNextMilestone().getPrevious();
  }
}

class StreakMilestone {
  final int day;
  final String name;

  StreakMilestone(this.day, {required this.name});

  bool isUnlocked() {
    return Hive.box("settings").get("streak.longest", defaultValue: 0) >= day;
  }

  bool shouldShowHint() {
    StreakMilestone? previous = getPrevious();
    return previous == null || previous.isUnlocked();
  }

  StreakMilestone? getPrevious() {
    int index = StreakManager.milestones.indexOf(this) - 1;
    if (index < 0) return null;
    return StreakManager.milestones[index];
  }
}