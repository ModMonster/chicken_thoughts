import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

class Vibrate {
  static bool _canVibrate() {
    return Hive.box("settings").get("vibration", defaultValue: true);
  }

  static Future<void> tap() async {
    if (!_canVibrate()) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> carousel() async {
    if (!_canVibrate()) return;
    await HapticFeedback.lightImpact();
  }
}