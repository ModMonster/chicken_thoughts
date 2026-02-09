import 'package:chicken_thoughts_notifications/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

String version = "2.0.0";

void main() {
  runApp(MaterialApp(
    title: "Chicken Thoughts",
    home: HomePage(),
    theme: ThemeData(
      colorSchemeSeed: Colors.purple
    ),
    darkTheme: ThemeData(
      colorSchemeSeed: Colors.purple,
      brightness: Brightness.dark
    ),
  ));
  // initNotifications();
}

Future<void> initNotifications() async {
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();  
  await notifications.initialize(settings: InitializationSettings(android: AndroidInitializationSettings("notification_icon")));

  // request permission on android 13+
  final AndroidFlutterLocalNotificationsPlugin? androidPlugin = notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  bool? success = await androidPlugin?.requestNotificationsPermission();
  if (success == null || !success) return;

  final now = TZDateTime.now(local);
  var scheduledDate = TZDateTime(
    local,
    now.year,
    now.month,
    now.day,
    7
  );

  await notifications.zonedSchedule(
    id: 0,
    scheduledDate: scheduledDate,
    matchDateTimeComponents: DateTimeComponents.time,
    title: "Daily Chicken Thought",
    body: "A new Chicken Thought is ready to read!",
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        "daily",
        "Daily Notifications",
        channelDescription: "Reminders every morning for new Chicken Thoughts",
        importance: Importance.low,
        priority: Priority.low,
        color: Colors.purple,
      )
    ),
  );
}