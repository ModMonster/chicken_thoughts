import 'package:chicken_thoughts_notifications/pages/settings_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_ce/hive.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart';

class NotificationManager {
  static const dailyChannelId = "daily";
  static const dailyChannelName = "Daily reminders";
  static const dailyChannelDescription = "Reminders every morning for new Chicken Thoughts";

  static final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();  
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );
    
    await notificationsPlugin.initialize(
      settings: initializationSettings
    );

    // request android notifications permission
    AndroidFlutterLocalNotificationsPlugin? androidNotifications = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidNotifications == null) return;

    await androidNotifications.requestNotificationsPermission();

    // create notifications channel
    androidNotifications.createNotificationChannel(
      AndroidNotificationChannel(
        dailyChannelId,
        dailyChannelName,
        description: dailyChannelDescription,
        importance: Importance.low,
      )
    );

    initializeTimeZones();
    final TimezoneInfo localTimeZone = await FlutterTimezone.getLocalTimezone();
    setLocalLocation(getLocation(localTimeZone.identifier));
    await scheduleDailyNotification();
  }

  static Future<void> scheduleDailyNotification() async {
    final TimeOfDay time = Hive.box("settings").get("notifications.time", defaultValue: TimeOfDay(hour: 7, minute: 0));

    final now = TZDateTime.now(local);
    var scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute
    );

    await notificationsPlugin.zonedSchedule(
      id: 0,
      scheduledDate: scheduledDate,
      matchDateTimeComponents: DateTimeComponents.time,
      title: "Daily Chicken Thought",
      body: "A new Chicken Thought is ready to read!",
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          dailyChannelId,
          dailyChannelName,
          icon: "ic_notification",
          channelDescription: dailyChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          color: colors[Hive.box("settings").get("color", defaultValue: 0)].color
        )
      ),
    );
  }
}