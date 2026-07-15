import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/data/share_manager.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/widgets/chicken_thought_image.dart';
import 'package:chicken_thoughts_notifications/widgets/streak_popup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DailyView extends StatelessWidget {
  final ChickenThought chickenThought;
  final ValueNotifier currentPageNotifier;
  const DailyView({required this.chickenThought, required this.currentPageNotifier, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chickenThought.displayName),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ChickenThoughtImage(chickenThought.images)
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {},
                        tooltip: "Add reaction",
                        icon: Icon(Icons.add_reaction),
                      ),
                      kIsWeb? Container() : IconButton(
                        onPressed: () {
                          Vibrate.tap();
                          ShareManager.share(chickenThought.id, displayName: chickenThought.displayName);
                        },
                        tooltip: "Share",
                        icon: Icon(Icons.share),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          StreakPopup(onTap: () {
            currentPageNotifier.value = 2;
          })
        ],
      )
    );
  }
}