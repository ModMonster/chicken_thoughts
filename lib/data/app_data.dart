import 'package:chicken_thoughts_notifications/main.dart';

class AppData {
  int latestVersion;
  int minVersion;
  bool offline;

  AppData({
    required this.latestVersion,
    required this.minVersion,
    this.offline = false
  });

  AppData.offline() :
    latestVersion = versionCode,
    minVersion = versionCode,
    offline = true;
}