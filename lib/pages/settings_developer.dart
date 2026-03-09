import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/net/cache_manager.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/set_streak_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class SettingsDeveloperPage extends StatefulWidget {
  const SettingsDeveloperPage({super.key});

  @override
  State<SettingsDeveloperPage> createState() => _SettingsDeveloperPageState();
}

class _SettingsDeveloperPageState extends State<SettingsDeveloperPage> {
  static const List<int> streakDaysOptions = [
    0, 10, 100, 365, 1000
  ];

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("settings");

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("Developer options"),
          ),
          SliverSafeArea(
            bottom: true,
            top: false,
            right: true,
            left: false,
            sliver: SliverList.list(
              children: [
                ListTile(
                  leading: Icon(Icons.cached_outlined),
                  title: Text("Clear cache"),
                  onTap: () async {
                    await CacheManager.deleteCaches();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Cleared caches!"),
                        behavior: SnackBarBehavior.floating,
                      ));
                    });
                  },
                ),
                ListTile(
                  title: Text("Set streak"),
                  leading: Icon(Icons.local_fire_department_outlined),
                  subtitle: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4.0,
                      children: [
                        ActionChip(
                          avatar: Icon(Icons.edit),
                          label: Text("Custom"),
                          onPressed: () {
                            Vibrate.tap();
                            showDialog(context: context, builder: (context) => SetStreakDialog());
                          },
                        ),
                        ...List.generate(streakDaysOptions.length, (index) =>
                          ActionChip(
                            label: Text("${streakDaysOptions[index]} days"),
                            onPressed: () {
                              Vibrate.tap();
                              box.put("streak", streakDaysOptions[index]);
                              if (box.get("streak.longest", defaultValue: 0) < streakDaysOptions[index] || streakDaysOptions[index] == 0) box.put("streak.longest", streakDaysOptions[index]);
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Set streak to ${streakDaysOptions[index]} days"),
                                behavior: SnackBarBehavior.floating,
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Text("Unlock full Chickendex"),
                  leading: Icon(Icons.add_circle_outline),
                  onTap: () async {
                    showDialog(context: context, builder: (context) => PopScope(
                      canPop: false,
                      child: Center(
                        child: LoadingIndicatorM3E(
                          variant: LoadingIndicatorM3EVariant.contained,
                        ),
                      ),
                    ));

                    Season season = await DatabaseManager.getDefaultSeason();
                    for (int i = 1; i <= season.imageCount; i++) {
                      await Hive.box("chickendex").put(i.toString(), 1);
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Unlocked all Chicken Thoughts! Note: this won't work with multi-image Chicken Thoughts, but that's fine since it's just for testing"),
                        behavior: SnackBarBehavior.floating,
                      ));
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8.0,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/icons/tai_tai.png"),
                        radius: 18,
                      ),
                      Text("Tai tai loves you!")
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      "Made with <3 by Maddie",
                      style: Theme.of(context).textTheme.labelMedium
                    )
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }
}