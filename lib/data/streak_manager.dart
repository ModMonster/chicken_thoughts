import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_launcher_icon/flutter_dynamic_launcher_icon.dart';
import 'package:hive_ce/hive.dart';

class StreakManager {
  static final List<StreakMilestone> milestones = [
    StreakMilestone(0, name: "Default", previewIcon: "assets/icons/default.png", androidAlias: null),
    StreakMilestone(7, name: "Egg", previewIcon: "assets/icons/egg.png", androidAlias: "EggAlias"),
    StreakMilestone(14, name: "Baby Chicken", previewIcon: "assets/icons/baby_chicken.png", androidAlias: "BabyChickenAlias"),
    StreakMilestone(30, name: "Roofus", previewIcon: "assets/icons/roofus.png", androidAlias: "RoofusAlias"),
    StreakMilestone(50, name: "Hackerbirb", previewIcon: "assets/icons/hackerbirb.png", androidAlias: "HackerbirbAlias"),
    StreakMilestone(75, name: "Sherlock Chicken", previewIcon: "assets/icons/sherlock_chicken.png", androidAlias: "SherlockChickenAlias"),
    StreakMilestone(100, name: "Blue Boy", previewIcon: "assets/icons/blue_boy.png", androidAlias: "BlueBoyAlias"),
    StreakMilestone(150, name: "Cas & Zeke", previewIcon: "assets/icons/cas_and_zeke.png", androidAlias: "CasAndZekeAlias"),
    StreakMilestone(200, name: "Real-Life Chicken", previewIcon: "assets/icons/real_life_chicken.png", androidAlias: "RealLifeChickenAlias"),
    StreakMilestone(300, name: "Tai Tai", previewIcon: "assets/icons/tai_tai.png", androidAlias: "TaiTaiAlias"),
    StreakMilestone(365, name: "Petrie", previewIcon: "assets/icons/petrie.png", androidAlias: "PetrieAlias"),
    StreakMilestone(400, name: "Prospector Chicken", previewIcon: "assets/icons/prospector_chicken.png", androidAlias: "ProspectorChickenAlias"),
    StreakMilestone(500, name: "Cordelia", previewIcon: "assets/icons/cordelia.png", androidAlias: "CordeliaAlias"),
    StreakMilestone(600, name: "Sammie", previewIcon: "assets/icons/sammie.png", androidAlias: "SammieAlias"),
    StreakMilestone(730, name: "Chicken Plushie", previewIcon: "assets/icons/chicken_plushie.png", androidAlias: "ChickenPlushieAlias"),
    StreakMilestone(1000, name: "Real-Life *Actual* Chicken", previewIcon: "assets/icons/real_actual_chicken.png", androidAlias: "RealActualChickenAlias"),
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
  final String previewIcon;
  final String? androidAlias;

  StreakMilestone(this.day, {required this.name, required this.previewIcon, this.androidAlias});

  bool isUnlocked() {
    return Hive.box("settings").get("streak.longest", defaultValue: 0) >= day;
  }

  bool shouldShowHint() {
    StreakMilestone? previous = getPrevious();
    return previous.isUnlocked();
  }

  StreakMilestone getPrevious() {
    int index = StreakManager.milestones.indexOf(this) - 1;
    if (index < 0) return StreakManager.milestones.first;
    return StreakManager.milestones[index];
  }

  Future<bool> activateThisIcon() async {
    await FlutterDynamicLauncherIcon.changeIcon(androidAlias);
    return await FlutterDynamicLauncherIcon.alternateIconName == androidAlias;
  }
}