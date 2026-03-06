import 'dart:math';

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

  static const streakReminderChannelId = "streak_reminders";
  static const streakReminderChannelName = "Streak reminders";
  static const streakReminderChannelDescription = "Notifications for if you are going to lose your streak";

  static final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications(ValueNotifier<int> currentPageNotifier) async {
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();  
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );
    
    await notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        currentPageNotifier.value = 0; // go to "daily" page on notification tap
      }
    );

    // request android notifications permission
    AndroidFlutterLocalNotificationsPlugin? androidNotifications = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidNotifications == null) return;

    await androidNotifications.requestNotificationsPermission();

    // create daily notifications channel
    androidNotifications.createNotificationChannel(
      AndroidNotificationChannel(
        dailyChannelId,
        dailyChannelName,
        description: dailyChannelDescription,
        importance: Importance.low,
      )
    );

    // create streak reminder notifications channel
    androidNotifications.createNotificationChannel(
      AndroidNotificationChannel(
        streakReminderChannelId,
        streakReminderChannelName,
        description: streakReminderChannelDescription,
        importance: Importance.high,
      )
    );

    initializeTimeZones();
    final TimezoneInfo localTimeZone = await FlutterTimezone.getLocalTimezone();
    setLocalLocation(getLocation(localTimeZone.identifier));
    await scheduleDailyNotification();
    await scheduleStreakReminderNotification();
  }

  static Future<void> scheduleStreakReminderNotification() async {
    notificationsPlugin.cancel(id: 1); // cancel existing warning notifications

    int streak = Hive.box("settings").get("streak", defaultValue: 0);
    if (streak == 0) return;

    final TimeOfDay time = Hive.box("settings").get("notifications.streak_reminder_time", defaultValue: TimeOfDay(hour: 20, minute: 0));

    final tomorrow = TZDateTime.now(local).add(Duration(days: 1));
    var scheduledDate = TZDateTime(
      local,
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      time.hour,
      time.minute
    );

    List<String> chickenstreakReminderMessages = [
      "Don't let your Chickenstreak fizzle out!",
      "Your Chickenstreak is in danger!",
      "Don't lose your Chickenstreak!",
    ];

    await notificationsPlugin.zonedSchedule(
      id: 1,
      scheduledDate: scheduledDate,
      title: chickenstreakReminderMessages[Random().nextInt(chickenstreakReminderMessages.length)],
      body: "View today's Chicken Thought so you don't lose your $streak day streak!",
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          streakReminderChannelId,
          streakReminderChannelName,
          icon: "ic_notification",
          channelDescription: streakReminderChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          color: colors[Hive.box("settings").get("color", defaultValue: 0)].color
        )
      ),
    );
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

    notificationsPlugin.cancel(id: 0); // hide the existing notification (if there is one)
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