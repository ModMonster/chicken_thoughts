import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/pages/settings_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final bool hasDynamicColor;
  const SettingsPage({required this.hasDynamicColor, super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String getCurrentThemeName() {
    switch (Hive.box("settings").get("theme")) {
      case 1:
        return "Light";
      case 2:
        return "Dark";
      default:
        return "System default";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("settings");

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("Settings"),
          ),
          SliverSafeArea(
            bottom: true,
            top: false,
            sliver: SliverList.list(
              children: [
                ListTile(
                  title: Text("Theme"),
                  subtitle: Text(getCurrentThemeName()),
                  leading: Icon(Icons.palette_outlined),
                  onTap: () {
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        title: Text("Choose theme"),
                        contentPadding: EdgeInsets.only(top: 8.0),
                        content: StatefulBuilder(
                          builder: (context, setState2) {
                            // Putting this directly in doesn't work.
                            // Do not ask me why, I have literally no idea.
                            int val = box.get("theme", defaultValue: 0);
                            
                            return RadioGroup(
                              groupValue: val,
                              onChanged: (value) {
                                if (value == null) return;
                                setState2(() {
                                  box.put("theme", value);
                                });
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile(
                                    value: 1,
                                    title: Text("Light"),
                                  ),
                                  RadioListTile(
                                    value: 2,
                                    title: Text("Dark"),
                                  ),
                                  RadioListTile(
                                    value: 0,
                                    title: Text("System default"),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("OK")
                          )
                        ],
                      );
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.brush_outlined),
                  title: Text("Color scheme"),
                  subtitle: Text(colors[box.get("color", defaultValue: widget.hasDynamicColor? 0 : 3)].name),
                  onTap: () {
                    Navigator.pushNamed(context, "/settings/color");
                  },
                ),
                ListTile(
                  title: Text("Notifications"),
                  leading: Icon(Icons.notifications_outlined),
                  onTap: () {
                    Navigator.pushNamed(context, "/settings/notifications");
                  },
                  enabled: false,
                  subtitle: Text("Coming soon"),
                ),
                SwitchListTile(
                  value: box.get("update_notifications", defaultValue: true),
                  onChanged: (value) {
                    box.put("update_notifications", value);
                  },
                  title: Text("Update prompts"),
                  subtitle: Text("Show an alert if a new update is available"),
                  secondary: Icon(Icons.update_outlined),
                ),
                Divider(),
                ListTile(
                  title: Text("View on GitHub"),
                  leading: Icon(Icons.code),
                  onTap: () {launchUrl(Uri.parse(githubUrl), mode: LaunchMode.externalApplication);},
                ),
                ListTile(
                  title: Text("Report a bug"),
                  leading: Icon(Icons.bug_report_outlined),
                  onTap: () {launchUrl(Uri.parse("$githubUrl/issues/new"), mode: LaunchMode.externalApplication);},
                ),
                AboutListTile(
                  icon: Icon(Icons.info_outline),
                  applicationVersion: version,
                  applicationIcon: CircleAvatar(backgroundImage: AssetImage("assets/icon.png")),
                  aboutBoxChildren: [
                    Text("An app that sends you a new Chicken Thought every day!")
                  ]
                )
              ]
            ),
          )
        ],
      ),
    );
  }
}