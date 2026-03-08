import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_launcher_icon/flutter_dynamic_launcher_icon.dart';
import 'package:hive_ce/hive.dart';

class StreakManager {
  static final List<StreakMilestone> milestones = [
    StreakMilestone(0, name: "Default", description: "god this guy is rude", previewIcon: "assets/icons/default.png", androidAlias: null),
    StreakMilestone(7, name: "Egg", description: "my butt hurts", previewIcon: "assets/icons/egg.png", androidAlias: "EggAlias"),
    StreakMilestone(14, name: "Baby Chicken", description: "just a lil guy!!", previewIcon: "assets/icons/baby_chicken.png", androidAlias: "BabyChickenAlias"),
    StreakMilestone(30, name: "Roofus", description: "can i help u?", previewIcon: "assets/icons/roofus.png", androidAlias: "RoofusAlias"),
    StreakMilestone(50, name: "Hackerbirb", description: "i'm in.", previewIcon: "assets/icons/hackerbirb.png", androidAlias: "HackerbirbAlias"),
    StreakMilestone(75, name: "Sherlock Chicken", description: "whoever ate my food left this trail of crumbs. they should lead me right to the culprit!", previewIcon: "assets/icons/sherlock_chicken.png", androidAlias: "SherlockChickenAlias"),
    StreakMilestone(100, name: "Blue Boy", description: "GET THAT THING OUT OF MY FACE!!!!", previewIcon: "assets/icons/blue_boy.png", androidAlias: "BlueBoyAlias"),
    StreakMilestone(150, name: "Cas & Zeke", description: "human would never believe the snake i just saw", previewIcon: "assets/icons/cas_and_zeke.png", androidAlias: "CasAndZekeAlias"),
    StreakMilestone(200, name: "Real-Life Chicken", description: "omg", previewIcon: "assets/icons/real_life_chicken.png", androidAlias: "RealLifeChickenAlias"),
    StreakMilestone(300, name: "Tai Tai", description: "tai tai good boy! tai tai loves you", previewIcon: "assets/icons/tai_tai.png", androidAlias: "TaiTaiAlias"),
    StreakMilestone(365, name: "Petrie", description: "sharin is carin!", previewIcon: "assets/icons/petrie.png", androidAlias: "PetrieAlias"),
    StreakMilestone(400, name: "Prospector Chicken", description: "gold!!", previewIcon: "assets/icons/prospector_chicken.png", androidAlias: "ProspectorChickenAlias"),
    StreakMilestone(500, name: "Cordelia", description: "no fly. come get.", previewIcon: "assets/icons/cordelia.png", androidAlias: "CordeliaAlias"),
    StreakMilestone(600, name: "Sammie", description: "a pinch for you, a pinch for me", previewIcon: "assets/icons/sammie.png", androidAlias: "SammieAlias"),
    StreakMilestone(730, name: "Chicken Plushie", description: "only \$34.99 plus shipping and processing!", previewIcon: "assets/icons/chicken_plushie.png", androidAlias: "ChickenPlushieAlias"),
    StreakMilestone(1000, name: "Actual Chicken", description: "cluck", previewIcon: "assets/icons/real_actual_chicken.png", androidAlias: "RealActualChickenAlias"),
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
    int streak = Hive.box("settings").get("streak", defaultValue: 0);
    for (int i = 0; i < milestones.length; i++) {
      if (streak < milestones[i].day) return milestones[i];
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
  final String description;
  final String previewIcon;
  final String? androidAlias;

  StreakMilestone(this.day, {required this.name, required this.description, required this.previewIcon, this.androidAlias});

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