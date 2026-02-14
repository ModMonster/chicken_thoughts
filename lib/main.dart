import 'package:chicken_thoughts_notifications/pages/home.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/settings.dart';
import 'package:chicken_thoughts_notifications/pages/settings_color.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';

String version = "2.0.0";

// TODO: settings ideas:
  // notifications, set time they happen
  // theme (obviously)
  // cache images

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseManager.init();
  await Hive.initFlutter();
  await Hive.openBox("settings");

  runApp(ChickenThoughtsApp());
  // initNotifications();
}

class ChickenThoughtsApp extends StatelessWidget {
  const ChickenThoughtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("settings");

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        bool hasDynamicColor = lightDynamic != null && darkDynamic != null;

        // Use color schemes based on the user's wallpaper
        if (hasDynamicColor) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Otherwise, use fallback
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.purple,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          );
        }

        return StreamBuilder(
          stream: box.watch(),
          builder: (context, asyncSnapshot) {
            return MaterialApp(
              title: "Chicken Thoughts",
              themeMode: ThemeMode.values[box.get("theme", defaultValue: 0)],
              theme: ThemeData(
                colorScheme: lightColorScheme
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme
              ),
              routes: {
                "/": (context) => HomePage(),
                "/settings": (context) => SettingsPage(hasDynamicColor: hasDynamicColor),
                "/settings/color": (context) => SettingsColorPage(hasDynamicColor: hasDynamicColor)
              },
            );
          }
        );
      }
    );
  }
}

// Future<void> initNotifications() async {
//   final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();  
//   await notifications.initialize(settings: InitializationSettings(android: AndroidInitializationSettings("notification_icon")));

//   // request permission on android 13+
//   final AndroidFlutterLocalNotificationsPlugin? androidPlugin = notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//   bool? success = await androidPlugin?.requestNotificationsPermission();
//   if (success == null || !success) return;

//   final now = TZDateTime.now(local);
//   var scheduledDate = TZDateTime(
//     local,
//     now.year,
//     now.month,
//     now.day,
//     7
//   );

//   await notifications.zonedSchedule(
//     id: 0,
//     scheduledDate: scheduledDate,
//     matchDateTimeComponents: DateTimeComponents.time,
//     title: "Daily Chicken Thought",
//     body: "A new Chicken Thought is ready to read!",
//     androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//     notificationDetails: NotificationDetails(
//       android: AndroidNotificationDetails(
//         "daily",
//         "Daily Notifications",
//         channelDescription: "Reminders every morning for new Chicken Thoughts",
//         importance: Importance.low,
//         priority: Priority.low,
//         color: Colors.purple,
//       )
//     ),
//   );
// }