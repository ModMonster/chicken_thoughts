import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_icon_changer/flutter_app_icon_changer.dart';
import 'package:hive_ce/hive.dart';

class StreakManager {
  static final List<StreakMilestone> milestones = [
    StreakMilestone(0, name: "Default", previewPath: "assets/icons/default.png", androidIcon: "MainActivity", isDefaultIcon: true),
    StreakMilestone(7, name: "Egg", previewPath: "assets/icons/egg.png", androidIcon: "EggAlias"),
    StreakMilestone(14, name: "Baby Chicken", previewPath: "assets/icons/baby_chicken.png", androidIcon: "BabyChickenAlias"),
    StreakMilestone(30, name: "Roofus", previewPath: "assets/icons/roofus.png", androidIcon: "RoofusAlias"),
    StreakMilestone(50, name: "Hackerbirb", previewPath: "assets/icons/hackerbirb.png", androidIcon: "HackerbirbAlias"),
    StreakMilestone(75, name: "Sherlock Chicken", previewPath: "assets/icons/sherlock_chicken.png", androidIcon: "SherlockChickenAlias"),
    StreakMilestone(100, name: "Blue Boy", previewPath: "assets/icons/blue_boy.png", androidIcon: "BlueBoyAlias"),
    StreakMilestone(150, name: "Cas & Zeke", previewPath: "assets/icons/cas_and_zeke.png", androidIcon: "CasAndZekeAlias"),
    StreakMilestone(200, name: "Real-Life Chicken", previewPath: "assets/icons/real_life_chicken.png", androidIcon: "RealLifeChickenAlias"),
    StreakMilestone(300, name: "Tai Tai", previewPath: "assets/icons/tai_tai.png", androidIcon: "TaiTaiAlias"),
    StreakMilestone(365, name: "Petrie", previewPath: "assets/icons/petrie.png", androidIcon: "PetrieAlias"),
    StreakMilestone(400, name: "Prospector Chicken", previewPath: "assets/icons/prospector_chicken.png", androidIcon: "ProspectorChickenAlias"),
    StreakMilestone(500, name: "Cordelia", previewPath: "assets/icons/cordelia.png", androidIcon: "CordeliaAlias"),
    StreakMilestone(600, name: "Sammie", previewPath: "assets/icons/sammie.png", androidIcon: "SammieAlias"),
    StreakMilestone(730, name: "Chicken Plushie", previewPath: "assets/icons/chicken_plushie.png", androidIcon: "ChickenPlushieAlias"),
    StreakMilestone(1000, name: "Real-Life *Actual* Chicken", previewPath: "assets/icons/real_actual_chicken.png", androidIcon: "RealActualChickenAlias"),
  ];

  static final FlutterAppIconChangerPlugin appIconChangerPlugin = FlutterAppIconChangerPlugin(iconsSet: milestones);

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

  static Future<bool> activateAppIcon(StreakMilestone milestone) {
    return milestone.activateThisIcon(appIconChangerPlugin);
  }
}

class StreakMilestone extends AppIcon {
  final int day;
  final String name;
  final String previewPath;

  StreakMilestone(this.day, {required this.name, required this.previewPath, required super.androidIcon, super.iOSIcon = "", super.isDefaultIcon = false});

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

  Future<bool> activateThisIcon(FlutterAppIconChangerPlugin plugin) async {
    try {
      return await plugin.changeIcon(currentIcon) ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) print("Failed to change app icon: exception $e");
      return false;
    }
  }
}