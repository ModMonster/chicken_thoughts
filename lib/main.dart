import 'package:chicken_thoughts_notifications/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String version = "1.2.1";

void main() {
  runApp(MaterialApp(
    title: "Chicken Thoughts",
    home: HomePage(),
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.purple
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.purple,
      brightness: Brightness.dark
    ),
  ));
  initNotifications();
}

Future<void> initNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin.initialize(InitializationSettings(android: AndroidInitializationSettings("notification_icon")));

  await flutterLocalNotificationsPlugin.showDailyAtTime(
    0,
    "Daily Chicken Thought",
    "A new Chicken Thought is ready to read!",
    Time(7, 0, 0),
    NotificationDetails(
      android: AndroidNotificationDetails(
        "other",
        "Other",
        importance: Importance.low,
        priority: Priority.low,
        color: Colors.blue,
      )
    ),
  );
}