import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

class Vibrate {
  static late final bool _hasVibrator;

  static Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  static Future<void> custom({int milliseconds = 500, int amplitude = -1}) async {
    if (!_hasVibrator) return;
    await Vibration.vibrate(duration: milliseconds, amplitude: amplitude);
  }

  static Future<void> preset(VibrationPreset preset) async {
    if (!_hasVibrator) return;
    await Vibration.vibrate(preset: preset);
  }

  static Future<void> tap() async {
    if (!_hasVibrator) return;
    await Vibration.vibrate(duration: 5, amplitude: 128);
  }

  static Future<void> carousel() async {
    if (!_hasVibrator) return;
    await Vibration.vibrate(duration: 1, amplitude: 64);
  }
}