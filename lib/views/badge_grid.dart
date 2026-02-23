import 'package:chicken_thoughts_notifications/data/streak_manager.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class BadgeGrid extends StatelessWidget {
  const BadgeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          bool isUnlocked = milestone.isUnlocked();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: isUnlocked? Stack(
                    children: [
                      Positioned.fill(
                        child: CircleAvatar(
                          backgroundImage: AssetImage(milestone.previewPath),
                          maxRadius: double.infinity,
                        ),
                      ),
                      if (!kIsWeb) Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: Durations.medium2,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: Tween<double>(begin: 1.2, end: 1).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Visibility(
                            visible: Hive.box("settings").get("app_icon", defaultValue: 0) == index,
                            key: ValueKey(Hive.box("settings").get("app_icon", defaultValue: 0) == index),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primaryContainer.withAlpha(192),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!kIsWeb) Positioned.fill(
                        child: Material(
                          shape: CircleBorder(),
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: CircleBorder(),
                            onTap: () async {
                              Vibrate.tap();
                              if (Hive.box("settings").get("app_icon", defaultValue: 0) == index) return;
                              bool success = await StreakManager.activateAppIcon(milestone);
                              if (!success) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Failed to change app icon."),
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                });
                              }

                              Hive.box("settings").put("app_icon", index);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Changed app icon to ${milestone.name}."),
                                  behavior: SnackBarBehavior.floating,
                                ));
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  ) : Material(
                    shape: CircleBorder(),
                    color: showHint? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
                    child: InkWell(
                      customBorder: CircleBorder(),
                      onTap: () {
                        Vibrate.tap();
                        showDialog(context: context, builder: (context) => AlertDialog(
                          title: Text("Locked!"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16,
                            children: [
                              Text("This badge is locked."),
                              Text("It will be unlocked once you've reached a ${milestone.day} day streak!")
                            ],
                          ),
                          actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("OK")
                          )
                        ],
                        ));
                      },
                      child: Center(
                        child: Icon(
                          Icons.lock,
                          color: showHint? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimaryContainer,
                          size: 48,
                        ),
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
    );
  }
}