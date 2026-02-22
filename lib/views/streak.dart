import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class StreakView extends StatelessWidget {
  const StreakView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chickenstreak"),
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
                    Hive.box("settings").get("streak", defaultValue: 309).toString(),
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
      ),
    );
  }
}