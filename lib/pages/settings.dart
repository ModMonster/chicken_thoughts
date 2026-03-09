import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/data/streak_manager.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/settings_color.dart';
import 'package:chicken_thoughts_notifications/widgets/settings_developer_totp_dialog.dart';
import 'package:chicken_thoughts_notifications/widgets/update_dialog.dart';
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
            right: true,
            left: false,
            sliver: SliverList.list(
              children: [
                if (kDebugMode) ListTile(
                  title: Text("Developer options"),
                  leading: Icon(Icons.handyman_outlined),
                  onTap: () {
                    Navigator.pushNamed(context, "/settings/dev");
                  },
                ),
                if (updateAvailable) ListTile(
                  title: Text("Update available"),
                  subtitle: Text("Tap to download the new update"),
                  leading: Icon(Icons.update),
                  onTap: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) =>
                      showDialog(context: context, barrierDismissible: true, builder: (context) {
                        return UpdateDialog(required: false, autostart: true);
                      })
                    );
                  },
                ),
                if (isAndroidWeb) ListTile(
                  title: Text("Download the app!"),
                  subtitle: Text("Tap to open download page"),
                  leading: Icon(Icons.downloading_outlined),
                  onTap: () {
                    launchUrl(Uri.parse("https://github.com/$githubRepo/releases/latest"), mode: LaunchMode.externalApplication);
                  },
                ),
                if (isAndroidWeb || updateAvailable || kDebugMode) Divider(),
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
                if (!kIsWeb) ListTile(
                  leading: Icon(Icons.app_registration_outlined),
                  title: Text("App icon"),
                  subtitle: Text(
                    StreakManager.milestones[box.get("app_icon", defaultValue: 0)].name
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, "/settings/icon");
                  },
                ),
                if (!kIsWeb) SwitchListTile(
                  value: box.get("vibration", defaultValue: true),
                  onChanged: (value) {
                    box.put("vibration", value);
                    Vibrate.tap();
                  },
                  title: Text("Vibration"),
                  secondary: Icon(Icons.vibration_outlined),
                ),
                if (!kIsWeb) Divider(),
                if (!kIsWeb) ListTile(
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
                    Vibrate.tap();
                  },
                  title: Text("Update prompts"),
                  subtitle: Text("Show a popup when an optional app update is available"),
                  secondary: Icon(Icons.update_outlined),
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
                            onPressed: () async {
                              Hive.box("chickendex").clear();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text("The Chickendex has been cleared!")
                                )
                              );

                              // re-add today's chicken thought
                              ChickenThought today = await DatabaseManager.getDailyChickenThought();
                              Hive.box("chickendex").put(today.id, today.images.length);
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
                  onTap: () {
                    launchUrl(Uri.parse("https://github.com/$githubRepo"), mode: LaunchMode.externalApplication);
                  },
                ),
                ListTile(
                  title: Text("Report a bug"),
                  leading: Icon(Icons.bug_report_outlined),
                  onTap: () {
                    launchUrl(Uri.parse("https://github.com/$githubRepo/issues/new"), mode: LaunchMode.externalApplication);
                  },
                ),
                GestureDetector(
                  onLongPress: () {
                    Vibrate.tap();
                    // skip totp in debug mode
                    if (kDebugMode) {
                      Navigator.pushNamed(context, "/settings/dev");
                      return;
                    }

                    // developer totp dialog
                    showDialog(context: context, builder: (context) => SettingsDeveloperTotpDialog());
                  },
                  child: AboutListTile(
                    icon: Icon(Icons.info_outline),
                    applicationVersion: version,
                    applicationIcon: CircleAvatar(
                      backgroundImage: AssetImage(
                        StreakManager.milestones[Hive.box("settings").get("app_icon", defaultValue: 0)].previewIcon
                      )
                    ),
                    aboutBoxChildren: [
                      Text("An app that sends you a new Chicken Thought every day!")
                    ],
                  ),
                )
              ]
            ),
          )
        ],
      ),
    );
  }
}