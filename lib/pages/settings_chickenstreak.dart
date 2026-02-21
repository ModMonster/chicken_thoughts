import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class SettingsChickenStreakPage extends StatelessWidget {
  const SettingsChickenStreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("Chicken Streak"),
          ),
          SliverSafeArea(
            bottom: true,
            top: false,
            right: true,
            left: false,
            sliver: SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12.0,
                    children: [
                      Text(
                        Hive.box("settings").get("streak", defaultValue: 0).toString(),
                        style: TextStyle(
                          fontSize: 72
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8.0,
                    children: List<Widget>.generate(5, (i) =>
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i >= 2? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.primary,
                        ),
                      )
                    )
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}