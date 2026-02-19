import 'package:hive_ce/hive.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

class Vibrate {
  static late final bool hasVibrator;

  static Future<void> init() async {
    hasVibrator = await Vibration.hasVibrator();
  }

  static bool _canVibrate() {
    return hasVibrator && Hive.box("settings").get("vibration", defaultValue: true);
  }

  static Future<void> custom({int milliseconds = 500, int amplitude = -1}) async {
    if (!_canVibrate()) return;
    await Vibration.vibrate(duration: milliseconds, amplitude: amplitude);
  }

  static Future<void> preset(VibrationPreset preset) async {
    if (!_canVibrate()) return;
    await Vibration.vibrate(preset: preset);
  }

  static Future<void> tap() async {
    if (!_canVibrate()) return;
    await Vibration.vibrate(duration: 5, amplitude: 128);
  }

  static Future<void> carousel() async {
    if (!_canVibrate()) return;
    await Vibration.vibrate(duration: 1, amplitude: 64);
  }
}