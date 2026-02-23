import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class StreakManager {
  static final List<StreakMilestone> milestones = [
    StreakMilestone(7, name: "Egg", fgPath: "assets/icons/egg.png"),
    StreakMilestone(14, name: "Baby Chicken", fgPath: "assets/icons/baby_chicken.png"),
    StreakMilestone(30, name: "Roofus", fgPath: "assets/icons/roofus.png"),
    StreakMilestone(50, name: "Hackerbirb", fgPath: "assets/icons/hackerbirb_fg.png", bgPath: "assets/icons/hackerbirb_bg.png"),
    StreakMilestone(75, name: "Sherlock Chicken", fgPath: "assets/icons/sherlock_chicken.png"),
    StreakMilestone(100, name: "Blue Boy", fgPath: "assets/icons/blue_boy.png"),
    StreakMilestone(150, name: "Cas & Zeke", fgPath: "assets/icons/cas_and_zeke.png"),
    StreakMilestone(200, name: "Real-Life Chicken", fgPath: "assets/icons/real_life_chicken.png"),
    StreakMilestone(300, name: "Tai Tai", fgPath: "assets/icons/tai_tai.png"),
    StreakMilestone(365, name: "Petrie", fgPath: "assets/icons/petrie.png"),
    StreakMilestone(400, name: "Prospector Chicken", fgPath: "assets/icons/prospector_chicken.png"),
    StreakMilestone(500, name: "Cordelia", fgPath: "assets/icons/cordelia.png"),
    StreakMilestone(600, name: "Sammie", fgPath: "assets/icons/sammie.png"),
    StreakMilestone(730, name: "Chicken Plushie", fgPath: "assets/icons/chicken_plushie.png"),
    StreakMilestone(1000, name: "Real-Life *Actual* Chicken", fgPath: "assets/icons/real_actual_chicken.png"),
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
  final String fgPath;
  final String bgPath;

  StreakMilestone(this.day, {required this.name, this.fgPath = "assets/icons/default_fg.png", this.bgPath = "assets/icons/default_bg.png"});

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