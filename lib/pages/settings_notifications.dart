import 'package:app_settings/app_settings.dart';
import 'package:chicken_thoughts_notifications/data/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class SettingsNotificationPage extends StatefulWidget {
  const SettingsNotificationPage({super.key});

  @override
  State<SettingsNotificationPage> createState() => _SettingsNotificationPageState();
}

class _SettingsNotificationPageState extends State<SettingsNotificationPage> {
  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("settings");

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("Notifications"),
          ),
          SliverSafeArea(
            bottom: true,
            top: false,
            right: true,
            left: false,
            sliver: SliverList.list(
              children: [
                ListTile(
                  title: Text("Notification time"),
                  subtitle: Text(box.get("notifications.time", defaultValue: TimeOfDay(hour: 7, minute: 0)).format(context)),
                  leading: Icon(Icons.access_time_outlined),
                  onTap: () async {
                    TimeOfDay? chosenTime = await showTimePicker(
                      context: context,
                      initialTime: box.get("notifications.time", defaultValue: TimeOfDay(hour: 7, minute: 0)),
                    );
                    if (chosenTime == null) return;
                    box.put("notifications.time", chosenTime);
                    await NotificationManager.scheduleDailyNotification();
                  }
                ),
                ListTile(
                  title: Text("Android notification settings"),
                  leading: Icon(Icons.open_in_new_outlined),
                  onTap: () {
                    AppSettings.openAppSettings(type: AppSettingsType.notification);
                  }
                ),
              ]
            )
          )
        ]
      )
    );
  }
}