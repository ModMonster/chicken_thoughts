import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/pages/settings_color.dart';
import 'package:flutter/foundation.dart';
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
                  title: Text("Color tint"),
                  subtitle: Text(colors[box.get("color", defaultValue: widget.hasDynamicColor? 0 : 3)].name),
                  onTap: () {
                    Navigator.pushNamed(context, "/settings/color");
                  },
                ),
                Divider(),
                ListTile(
                  title: Text("Notifications"),
                  leading: Icon(Icons.notifications_outlined),
                  onTap: () {
                    Navigator.pushNamed(context, "/settings/notifications");
                  },
                ),
                if (!kIsWeb) SwitchListTile(
                  value: box.get("update_notifications", defaultValue: true),
                  onChanged: (value) {
                    box.put("update_notifications", value);
                  },
                  title: Text("Update prompts"),
                  subtitle: Text("Show an alert if a new app update is available"),
                  secondary: Icon(Icons.update_outlined),
                ),
                if (!kIsWeb) ListTile(
                  title: Text("Caching"),
                  leading: Icon(Icons.cached_outlined),
                  onTap: () {
                    Navigator.pushNamed(context, "/settings/caching");
                  },
                  subtitle: Text(box.get("caching.enable", defaultValue: false)? "On" : "Off"),
                ),
                Divider(),
                ListTile(
                  title: Text("Clear Chickendex"),
                  leading: Icon(Icons.delete_outline),
                  onTap: () {
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        title: Text("Clear Chickendex"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12.0,
                          children: [
                            Text("Are you sure you want to clear your Chickendex?"),
                            Text("This will clear all of the Chicken Thoughts you have previously unlocked."),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel")
                          ),
                          TextButton(
                            onPressed: () {
                              Hive.box("chickendex").clear();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text("The Chickendex has been cleared!")
                                )
                              );
                            },
                            child: Text("OK"),
                          )
                        ],
                      );
                    });
                  },
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