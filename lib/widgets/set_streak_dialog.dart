import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class SetStreakDialog extends StatefulWidget {
  const SetStreakDialog({super.key});

  @override
  State<SetStreakDialog> createState() => _SetStreakDialogState();
}

class _SetStreakDialogState extends State<SetStreakDialog> {
  final TextEditingController _streakController = TextEditingController();
  final TextEditingController _longestStreakController = TextEditingController();

  @override
  void initState() {
    _streakController.text = Hive.box("settings").get("streak", defaultValue: 0).toString();
    _longestStreakController.text = Hive.box("settings").get("streak.longest", defaultValue: 0).toString();

    super.initState();
  }

  void _save() {
    ScaffoldMessenger.of(context).clearSnackBars();

    int? streak = int.tryParse(_streakController.text);
    int? longestStreak = int.tryParse(_longestStreakController.text);

    if (streak == null || longestStreak == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Couldn't update streak; invalid input."),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    if (longestStreak < streak) {
      longestStreak = streak;
    }

    Hive.box("settings").put("streak", streak);
    Hive.box("settings").put("streak.longest", longestStreak);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Updated streak!"),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Set streak"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _streakController,
            autofocus: true,
            decoration: InputDecoration(
              label: Text("Current streak")
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              int? streak = int.tryParse(value);
              int? longestStreak = int.tryParse(_longestStreakController.text);

              if (streak != null && (longestStreak == null || longestStreak < streak)) {
                _longestStreakController.text = streak.toString();
              }
            },
          ),
          TextField(
            controller: _longestStreakController,
            decoration: InputDecoration(
              label: Text("Longest streak")
            ),
            keyboardType: TextInputType.number,
            onEditingComplete: () {
              int? streak = int.tryParse(_streakController.text);
              int? longestStreak = int.tryParse(_longestStreakController.text);

              if (streak != null && (longestStreak == null || longestStreak < streak)) {
                _longestStreakController.text = streak.toString();
              }
            },
            onSubmitted: (value) {
              _save();
              Navigator.pop(context);
            },
          )
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
            _save();
            Navigator.pop(context);
          },
          child: Text("OK")
        )
      ],
    );
  }
}