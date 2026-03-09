import 'dart:math';

import 'package:chicken_thoughts_notifications/data/streak_manager.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/widgets/shimmer_delayed.dart';
import 'package:chicken_thoughts_notifications/widgets/tilted_avatar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

class BadgeGrid extends StatelessWidget {
  const BadgeGrid({super.key});

  Widget _badgeFlipAnimationBuilder(BuildContext flightContext, Animation<double> animation, HeroFlightDirection flightDirection, BuildContext fromHeroContext, BuildContext toHeroContext) {
    final Widget toHero = toHeroContext.widget;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        double value = animation.value;

        // Flip when flying
        double angle = value * pi;
        if (flightDirection == HeroFlightDirection.pop) {
          angle = (1 - value) * pi;
        }

        // Flip halfway
        if (flightDirection == HeroFlightDirection.push && value > 0.5 || flightDirection == HeroFlightDirection.pop && value <= 0.5) {
          angle -= pi;
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateY(angle),
          child: child,
        );
      },
      child: toHero,
    );
  }

  Future<void> _setAppIcon(BuildContext context, {required StreakMilestone milestone, required int index}) async {
    Vibrate.tap();
    if (Hive.box("settings").get("app_icon", defaultValue: 0) == index) return;

    bool success = await milestone.activateThisIcon();
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          childAspectRatio: 0.55,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 32.0
        ),
        itemCount: StreakManager.milestones.length,
        itemBuilder: (context, index) {
          StreakMilestone milestone = StreakManager.milestones[index];
          DateTime? unlockedDate = Hive.box("settings").get("streak.unlockDate.${milestone.day}");
          if (unlockedDate == null) {
            unlockedDate = DateTime.now()
              .subtract(Duration(days: Hive.box("settings").get("streak.longest", defaultValue: 0)))
              .add(Duration(days: milestone.day));
              Hive.box("settings").put("streak.unlockDate.${milestone.day}", unlockedDate);
          }

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
                        child: Hero(
                          tag: "badge-$index",
                          flightShuttleBuilder: _badgeFlipAnimationBuilder,
                          child: CircleAvatar(
                            backgroundImage: AssetImage(milestone.previewIcon),
                            maxRadius: double.infinity,
                          ),
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
                      Positioned.fill(
                        child: Material(
                          shape: CircleBorder(),
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: CircleBorder(),
                            onLongPress: kIsWeb? null : () {
                              _setAppIcon(context, milestone: milestone, index: index);
                            },
                            onTap: () {
                              Vibrate.tap();
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  opaque: false,
                                  barrierColor: Colors.black54,
                                  barrierDismissible: true,
                                  pageBuilder: (context, animation, animationOut) {
                                    final CurvedAnimation curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOut, reverseCurve: Curves.easeIn);
                                    return FadeTransition(
                                      opacity: curvedAnimation,
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                          curvedAnimation
                                        ),
                                        child: AlertDialog(
                                          clipBehavior: Clip.none,
                                          actions: [
                                            if (!kIsWeb) OutlinedButton.icon(
                                              onPressed: Hive.box("settings").get("app_icon", defaultValue: 0) == index? null : () async {
                                                _setAppIcon(context, milestone: milestone, index: index);
                                              },
                                              label: Text("Set as app icon"),
                                              icon: Icon(Hive.box("settings").get("app_icon", defaultValue: 0) == index? Icons.check : Icons.auto_awesome),
                                            ),
                                            TextButton(onPressed: () {
                                              Navigator.pop(context);
                                            }, child: Text("Close"))
                                          ],
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth: 300
                                                    ),
                                                    child: AspectRatio(
                                                      aspectRatio: 1,
                                                      child: Hero(
                                                        tag: "badge-$index",
                                                        child: Tilted(
                                                          child: ClipOval(
                                                            child: ShimmerDelayed(
                                                              interval: Duration(seconds: 2),
                                                              child: CircleAvatar(
                                                                backgroundImage: AssetImage(milestone.previewIcon),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 16.0),
                                                child: Text(
                                                  showHint? milestone.name : "???",
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context).textTheme.headlineMedium!,
                                                ),
                                              ),
                                              if (milestone.day > 0) Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Text(
                                                  "${milestone.day} day streak",
                                                  style: Theme.of(context).textTheme.labelMedium,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              if (milestone.day > 0) Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  "Unlocked on ${DateFormat("MMM d, yyyy").format(unlockedDate!)}",
                                                  style: Theme.of(context).textTheme.labelMedium,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 24.0),
                                                child: Text(
                                                  '"${milestone.description}"',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                )
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ) : Hero(
                    tag: "badge-$index",
                    flightShuttleBuilder: _badgeFlipAnimationBuilder,
                    child: Material(
                      shape: CircleBorder(),
                      color: showHint? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
                      child: InkWell(
                        customBorder: CircleBorder(),
                        onTap: () {
                          Vibrate.tap();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false,
                              barrierColor: Colors.black54,
                              barrierDismissible: true,
                              pageBuilder: (context, animation, animationOut) {
                                final CurvedAnimation curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOut, reverseCurve: Curves.easeIn);

                                return FadeTransition(
                                  opacity: curvedAnimation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
                                    child: AlertDialog(
                                      clipBehavior: Clip.none,
                                      actions: [
                                        TextButton(onPressed: () {
                                          Navigator.pop(context);
                                        }, child: Text("Close"))
                                      ],
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 16.0,
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: 300
                                                ),
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Hero(
                                                    tag: "badge-$index",
                                                    child: Material(
                                                      shape: CircleBorder(),
                                                      color: showHint? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.lock,
                                                          color: showHint? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimaryContainer,
                                                          size: 96,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              showHint? milestone.name : "???",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.headlineMedium!,
                                            ),
                                          ),
                                          Text("This badge is locked.", textAlign: TextAlign.center),
                                          Text("It will be unlocked once you've reached a ${milestone.day} day streak.", textAlign: TextAlign.center)
                                        ],
                                      ),
                                    )
                                  )
                                );
                              }
                            )
                          );
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
              ),
              Text(
                showHint? milestone.name : "???",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: showHint? null : Theme.of(context).colorScheme.onSurface.withAlpha(192)
                ),
                maxLines: 2,
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