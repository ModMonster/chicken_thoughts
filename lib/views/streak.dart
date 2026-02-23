import 'package:chicken_thoughts_notifications/data/streak_manager.dart';
import 'package:chicken_thoughts_notifications/views/badge_grid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

class StreakView extends StatelessWidget {
  const StreakView({super.key});

  @override
  Widget build(BuildContext context) {
    final int streak = Hive.box("settings").get("streak", defaultValue: 0);
    final StreakMilestone? latestMilestone = StreakManager.getLatestMilestone();
    final StreakMilestone nextMilestone = StreakManager.getNextMilestone();

    return Scaffold(
      appBar: AppBar(
        title: Text("Chickenstreak"),
        actions: [
          if (MediaQuery.of(context).size.width <= 600) IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
            icon: Icon(Icons.settings),
            tooltip: "Settings",
          )
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8.0,
                children: [
                  Text(
                    streak.toString(),
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Icon(
                    Icons.local_fire_department,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8.0,
                children: [
                  Text("${latestMilestone?.day ?? 0} days"),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 400
                      ),
                      child: LinearProgressIndicatorM3E(
                        shape: ProgressM3EShape.flat,
                        value: (streak - (latestMilestone?.day ?? 0)) / nextMilestone.day,
                      ),
                    ),
                  ),
                  Text("${nextMilestone.day} days")
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 36.0, 16.0, 16.0),
              child: Text(
                "Badges",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("Unlock badges by building your streak!${!kIsWeb? " Tap on an unlocked badge to use it as the app icon on the home screen." : ""}"),
              ),
            ),
            BadgeGrid()
          ],
        ),
      ),
    );
  }
}