import 'package:chicken_thoughts_notifications/data/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

final List<SettingsColor> colors = [
  SettingsColor("Match wallpaper", Colors.purple),
  SettingsColor("Red", Colors.red),
  SettingsColor("Pink", Colors.pink),
  SettingsColor("Purple", Colors.purple),
  SettingsColor("Deep purple", Colors.deepPurple),
  SettingsColor("Indigo", Colors.indigo),
  SettingsColor("Blue", Colors.blue),
  SettingsColor("Light blue", Colors.lightBlue),
  SettingsColor("Cyan", Colors.cyan),
  SettingsColor("Teal", Colors.teal),
  SettingsColor("Green", Colors.green),
  SettingsColor("Light green", Colors.lightGreen),
  SettingsColor("Lime", Colors.lime),
  SettingsColor("Yellow", Colors.yellow),
  SettingsColor("Amber", Colors.amber),
  SettingsColor("Orange", Colors.orange),
  SettingsColor("Deep orange", Colors.deepOrange),
  SettingsColor("Brown", Colors.brown),
  SettingsColor("Grey", Colors.grey),
  SettingsColor("Blue grey", Colors.blueGrey)
];

class SettingsColorPage extends StatelessWidget {
  final bool hasDynamicColor;
  final ColorScheme? dynamicColorScheme;
  const SettingsColorPage({required this.hasDynamicColor, required this.dynamicColorScheme, super.key});

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box("settings");
    int groupValue = box.get("color", defaultValue: hasDynamicColor? 0 : 3);

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
              title: Text("Choose color tint"),
            ),
            SliverSafeArea(
              bottom: true,
              top: false,
              right: true,
              left: false,
              sliver: SliverList.builder(
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    if (!hasDynamicColor) return Container();
                    return RadioListTile(
                      value: index,
                      controlAffinity: ListTileControlAffinity.trailing,
                      secondary: CircleAvatar(
                        backgroundColor: dynamicColorScheme!.primaryContainer,
                        foregroundColor: dynamicColorScheme!.onPrimaryContainer,
                        child: Icon(Icons.auto_awesome_outlined),
                      ),
                      title: Text("Match wallpaper")
                    );
                  }
                  
                  SettingsColor color = colors[index];
                  return RadioListTile(
                    value: index,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: CircleAvatar(
                      backgroundColor: color.color,
                    ),
                    title: Text(color.name)
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