import 'package:chicken_thoughts_notifications/data/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

class SettingsIconPage extends StatelessWidget {
  const SettingsIconPage({super.key});

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box("settings");
    int groupValue = 0;

    return Scaffold(
      body: RadioGroup(
        groupValue: groupValue,
        onChanged: (value) {
          box.put("color", value);
          NotificationManager.scheduleDailyNotification(); // we use the color for the notification, so reschedule when it's changed
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("Choose app icon"),
            ),
            SliverSafeArea(
              bottom: true,
              top: false,
              right: true,
              left: false,
              sliver: SliverList.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return RadioListTile(
                    value: index,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: CircleAvatar(
                      // backgroundColor: dynamicColorScheme!.primaryContainer,
                      // foregroundColor: dynamicColorScheme!.onPrimaryContainer,
                      child: Icon(Icons.auto_awesome_outlined),
                    ),
                    title: Text("Default")
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SettingsColor {
  String name;
  Color color;

  SettingsColor(this.name, this.color);
}