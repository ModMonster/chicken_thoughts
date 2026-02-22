import 'package:chicken_thoughts_notifications/data/streak_manager.dart';
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
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: ListView(
            children: [
              Row(
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
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Badges",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Unlock badges by building your streak!${!kIsWeb? " Unlocked badges can be used as the app icon on the home screen." : ""}"),
                ),
              ),
              if (!kIsWeb) Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                child: OutlinedButton(
                  onPressed: () {
                
                  },
                  child: Text("Open icon settings")
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    childAspectRatio: 0.6,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 32.0
                  ),
                  itemCount: StreakManager.milestones.length,
                  itemBuilder: (context, index) {
                    StreakMilestone milestone = StreakManager.milestones[index];
                    bool showHint = milestone.shouldShowHint();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: showHint? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer
                              ),
                              child: showHint? null : Center(
                                child: Icon(
                                  Icons.lock,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          showHint? milestone.name : "???",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: showHint? null : Theme.of(context).colorScheme.onSurface.withAlpha(192)
                          ),
                        ),
                        Text(
                          "${milestone.day} days",
                          style: Theme.of(context).textTheme.labelMedium,
                        )
                      ],
                    );
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}